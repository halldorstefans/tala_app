import 'dart:io';

import 'package:archive/archive.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../utils/result.dart';
import '../../database/app_database.dart' as db;
import 'backup_service.dart';

/// Directory (under app documents) where a picked backup is unpacked, pending
/// application on the next launch. A `.ready` marker inside it, written last,
/// signals a complete extraction.
const _stagingDirName = 'restore_staging';
const _readyMarkerName = '.ready';
const _dbFileName = 'tala.db';
const _photosDirName = 'photos';

class BackupServiceLocal implements BackupService {
  BackupServiceLocal({required db.AppDatabase database}) : _database = database;

  final db.AppDatabase _database;
  final _log = Logger('BackupServiceLocal');

  @override
  Future<Result<String>> createBackup() async {
    File? snapshot;
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final tmpDir = await getTemporaryDirectory();
      final stamp = _timestamp(DateTime.now());

      // 1. A consistent database snapshot. VACUUM INTO writes a clean copy
      // regardless of journal/WAL state, so the backup can't capture a
      // half-written file. The target must not already exist.
      final snapshotPath = p.join(tmpDir.path, 'tala-snapshot-$stamp.db');
      snapshot = File(snapshotPath);
      if (await snapshot.exists()) await snapshot.delete();
      await _database.customStatement(
        "VACUUM INTO '${snapshotPath.replaceAll("'", "''")}'",
      );

      // 2. Zip the snapshot (as tala.db) together with the photos directory.
      final archive = Archive()
        ..addFile(ArchiveFile.bytes('tala.db', await snapshot.readAsBytes()));

      final photosDir = Directory(p.join(docsDir.path, 'photos'));
      if (await photosDir.exists()) {
        await for (final entity in photosDir.list(recursive: true)) {
          if (entity is! File) continue;
          final rel = p.join(
            'photos',
            p.relative(entity.path, from: photosDir.path),
          );
          archive.addFile(ArchiveFile.bytes(rel, await entity.readAsBytes()));
        }
      }

      final zipBytes = ZipEncoder().encode(archive);
      final zipPath = p.join(tmpDir.path, 'tala-backup-$stamp.zip');
      await File(zipPath).writeAsBytes(zipBytes);

      return Result.ok(zipPath);
    } catch (e, st) {
      _log.severe('Exception in createBackup', e, st);
      return Result.error(Exception('Failed to create backup'));
    } finally {
      // Drop the intermediate snapshot; the zip is the deliverable.
      if (snapshot != null && await snapshot.exists()) {
        await snapshot.delete();
      }
    }
  }

  @override
  Future<Result<void>> stageRestore(String zipPath) async {
    try {
      final archive = ZipDecoder().decodeBytes(await File(zipPath).readAsBytes());

      // A Tala backup always contains the database at the archive root.
      final hasDb = archive.files.any((f) => f.isFile && f.name == _dbFileName);
      if (!hasDb) {
        return Result.error(
          Exception('Not a valid Tala backup (no database found)'),
        );
      }

      final docsDir = await getApplicationDocumentsDirectory();
      final staging = Directory(p.join(docsDir.path, _stagingDirName));
      if (await staging.exists()) await staging.delete(recursive: true);
      await staging.create(recursive: true);

      for (final file in archive.files) {
        if (!file.isFile) continue;
        // Only accept the db and photos/*, and guard against zip-slip.
        final name = p.normalize(file.name);
        if (p.isAbsolute(name) || name.startsWith('..')) continue;
        final isDb = name == _dbFileName;
        final isPhoto = p.split(name).first == _photosDirName;
        if (!isDb && !isPhoto) continue;

        final dest = File(p.join(staging.path, name));
        await dest.parent.create(recursive: true);
        await dest.writeAsBytes(file.content);
      }

      // Marker last: a crash mid-extraction leaves no `.ready`, so a partial
      // staging is never applied.
      await File(p.join(staging.path, _readyMarkerName)).writeAsString('ok');
      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Exception in stageRestore', e, st);
      return Result.error(Exception('Failed to prepare restore'));
    }
  }

  /// `YYYYMMDD-HHmmss`, filename-safe and sortable.
  String _timestamp(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}${two(d.month)}${two(d.day)}'
        '-${two(d.hour)}${two(d.minute)}${two(d.second)}';
  }
}

/// Applies a staged restore (from [BackupServiceLocal.stageRestore]) by moving
/// the staged database and photos into place. Must run in `main()` **before**
/// the database is opened — the swap can't happen under a live connection.
///
/// Idempotent and crash-safe: staging is only removed after a full apply, so an
/// interrupted apply is retried on the next launch. A no-op when nothing is
/// staged.
Future<void> applyPendingRestore() async {
  try {
    final docsDir = await getApplicationDocumentsDirectory();
    final staging = Directory(p.join(docsDir.path, _stagingDirName));
    final marker = File(p.join(staging.path, _readyMarkerName));
    if (!await marker.exists()) return;

    // Database: overwrite, and drop any stale WAL/SHM sidecars so SQLite can't
    // replay the old journal onto the restored file.
    final stagedDb = File(p.join(staging.path, _dbFileName));
    final liveDbPath = p.join(docsDir.path, _dbFileName);
    if (await stagedDb.exists()) {
      await stagedDb.copy(liveDbPath);
    }
    for (final suffix in const ['-wal', '-shm']) {
      final sidecar = File('$liveDbPath$suffix');
      if (await sidecar.exists()) await sidecar.delete();
    }

    // Photos: replace the directory wholesale.
    final stagedPhotos = Directory(p.join(staging.path, _photosDirName));
    final livePhotos = Directory(p.join(docsDir.path, _photosDirName));
    if (await livePhotos.exists()) await livePhotos.delete(recursive: true);
    if (await stagedPhotos.exists()) {
      await livePhotos.create(recursive: true);
      await for (final entity in stagedPhotos.list(recursive: true)) {
        if (entity is! File) continue;
        final dest = File(
          p.join(livePhotos.path, p.relative(entity.path, from: stagedPhotos.path)),
        );
        await dest.parent.create(recursive: true);
        await entity.copy(dest.path);
      }
    }

    // Only now that everything is in place: clear staging.
    await staging.delete(recursive: true);
  } catch (_) {
    // Best-effort. Staging is left intact on failure so the next launch can
    // retry rather than leaving the user half-restored with no recourse.
  }
}

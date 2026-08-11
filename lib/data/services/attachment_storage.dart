import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Centralizes on-disk storage for attachment files (and the vehicle cover
/// photo), replacing the `photos/<uuid>.<ext>` plumbing that was copy-pasted
/// across the repositories. Files live under `<app documents>/photos/`; the
/// relative path (`photos/<uuid>.<ext>`) is what gets persisted in the database.
class AttachmentStorage {
  const AttachmentStorage();

  static final _uuid = const Uuid();

  /// Copies [source] into the photos dir under a fresh uuid name (keeping the
  /// extension) and returns the relative path to persist.
  Future<String> save(File source) async {
    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(dir.path, 'photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    final relativePath = p.join('photos', '${_uuid.v4()}${p.extension(source.path)}');
    await source.copy(p.join(dir.path, relativePath));
    return relativePath;
  }

  /// Deletes the file backing [relativePath] if it exists. A missing file is
  /// tolerated (already gone).
  Future<void> delete(String relativePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, relativePath));
    if (await file.exists()) await file.delete();
  }

  /// Deletes the files backing every path in [relativePaths].
  Future<void> deleteAll(Iterable<String> relativePaths) async {
    final paths = relativePaths.toList();
    if (paths.isEmpty) return;
    final dir = await getApplicationDocumentsDirectory();
    for (final relativePath in paths) {
      final file = File(p.join(dir.path, relativePath));
      if (await file.exists()) await file.delete();
    }
  }
}

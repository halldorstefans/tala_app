import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tala_app/data/database/app_database.dart';

/// The riskiest part of the Attachments slice: the v3 -> v4 data migration that
/// folds `job_photos` and `part_photos` into `attachments` and drops the old
/// tables. Builds a real v3 database by hand, opens it at v4 (which triggers the
/// migration), and asserts the rows landed correctly.
void main() {
  late File dbFile;

  setUp(() {
    dbFile = File(
      '${Directory.systemTemp.path}/tala_mig_'
      '${DateTime.now().microsecondsSinceEpoch}.db',
    );
  });

  tearDown(() async {
    if (await dbFile.exists()) await dbFile.delete();
  });

  /// Writes a minimal v3 schema (just what the v3->v4 step reads) with seed
  /// rows, and stamps `user_version = 3` so Drift runs the upgrade.
  void writeV3Database() {
    final raw = sqlite3.open(dbFile.path);
    raw.execute('''
      CREATE TABLE jobs (id TEXT NOT NULL PRIMARY KEY);
      CREATE TABLE parts (id TEXT NOT NULL PRIMARY KEY);
      CREATE TABLE job_photos (
        id TEXT NOT NULL PRIMARY KEY,
        job_id TEXT NOT NULL,
        photo_path TEXT NOT NULL,
        created_at INTEGER NOT NULL DEFAULT 0
      );
      CREATE TABLE part_photos (
        id TEXT NOT NULL PRIMARY KEY,
        part_id TEXT NOT NULL,
        photo_path TEXT NOT NULL,
        created_at INTEGER NOT NULL DEFAULT 0
      );
      INSERT INTO jobs (id) VALUES ('j1');
      INSERT INTO parts (id) VALUES ('p1');
      INSERT INTO job_photos (id, job_id, photo_path, created_at)
        VALUES ('a', 'j1', 'photos/a.jpg', 100),
               ('b', 'j1', 'photos/b.jpg', 200);
      INSERT INTO part_photos (id, part_id, photo_path, created_at)
        VALUES ('c', 'p1', 'photos/c.jpg', 300);
      PRAGMA user_version = 3;
    ''');
    raw.close();
  }

  test('v3 -> v4 folds job_photos and part_photos into attachments', () async {
    writeV3Database();

    // Opening at v4 runs onUpgrade(3, 4) on first query.
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    final jobAttachments = await db.getAttachmentsForJob('j1');
    expect(
      jobAttachments.map((a) => a.storagePath),
      containsAll(['photos/a.jpg', 'photos/b.jpg']),
    );
    expect(jobAttachments.every((a) => a.type == 'photo'), isTrue);
    expect(jobAttachments.every((a) => a.partId == null), isTrue);

    final partAttachments = await db.getAttachmentsForPart('p1');
    expect(partAttachments.single.storagePath, 'photos/c.jpg');
    expect(partAttachments.single.type, 'photo');
    expect(partAttachments.single.jobId, isNull);

    // The old tables are dropped — attachments is the single source of truth.
    final tableNames = (await db
            .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
            .get())
        .map((row) => row.read<String>('name'))
        .toSet();
    expect(tableNames, contains('attachments'));
    expect(tableNames, isNot(contains('job_photos')));
    expect(tableNames, isNot(contains('part_photos')));
  });

  test('a fresh v4 install has no legacy photo tables', () async {
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    // Force onCreate by touching the schema.
    await db.getAttachmentsForJob('none');

    final tableNames = (await db
            .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
            .get())
        .map((row) => row.read<String>('name'))
        .toSet();
    expect(tableNames, contains('attachments'));
    expect(tableNames, isNot(contains('job_photos')));
    expect(tableNames, isNot(contains('part_photos')));
  });
}

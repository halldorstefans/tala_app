import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/data/database/app_database.dart' show AppDatabase;
import 'package:tala_app/data/repositories/jobs/jobs_repository_local.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/domain/models/progress_status.dart';
import 'package:tala_app/utils/result.dart';

/// Verifies the ProgressStatus enum survives a real SQLite round-trip storing
/// the unchanged wire string. This is the guarantee behind "no migration
/// needed": the column still holds 'in_progress', not the Dart identifier.
void main() {
  late AppDatabase db;
  late JobsRepositoryLocal repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = JobsRepositoryLocal(database: db);
  });

  tearDown(() async => db.close());

  test('status round-trips through the domain <-> Drift boundary', () async {
    for (final status in ProgressStatus.values) {
      final id = 'job-${status.wire}';
      await repo.addJob(
        'v1',
        Job(id: id, vehicleId: 'v1', title: 't', status: status),
      );

      final result = await repo.getJob('v1', id);
      expect(result, isA<Ok<Job>>());
      expect((result as Ok<Job>).value.status, status);

      // The raw column holds the wire string, unchanged from the pre-enum
      // schema — so existing rows keep working without a migration.
      final row = await db.getJobById(id);
      expect(row!.status, status.wire);
    }
  });

  test('an unrecognized stored status reads back as null (unknown)', () async {
    await repo.addJob(
      'v1',
      Job(id: 'j', vehicleId: 'v1', title: 't', status: ProgressStatus.planned),
    );
    // Simulate a legacy/unknown value written directly to the column.
    await db.customStatement("UPDATE jobs SET status = 'shelved' WHERE id = 'j'");

    final result = await repo.getJob('v1', 'j');
    expect((result as Ok<Job>).value.status, isNull);
  });
}

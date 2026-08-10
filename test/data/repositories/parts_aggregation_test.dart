import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/data/database/app_database.dart'
    show AppDatabase, JobPhotosCompanion;
import 'package:tala_app/data/repositories/jobs/jobs_repository_local.dart';
import 'package:tala_app/data/repositories/parts/parts_repository_local.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/domain/models/job_part.dart';
import 'package:tala_app/domain/models/part.dart';
import 'package:tala_app/utils/result.dart';

/// Real-SQLite coverage for the join/aggregate repository methods. These
/// replaced per-row (N+1) loops with single queries, and the fakes bypass SQL
/// entirely — so this is the only place the actual joins/totals are exercised.
///
/// Fixture (unit costs; a null cost contributes 0):
///   v1 / job j1: p1 x2 @10 (=20), p2 x1 @5 (=5)
///   v1 / job j2: p1 x1 @10 (=10), p3 x3 @null (=0)
///   v2 / job j3: p2 x5 @5 (=25)   <- must never leak into v1 rollups
void main() {
  late AppDatabase db;
  late PartsRepositoryLocal parts;
  late JobsRepositoryLocal jobs;

  T ok<T>(Result<T> r) => switch (r) {
    Ok<T>(:final value) => value,
    Error<T>(:final error) => throw error,
  };

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    parts = PartsRepositoryLocal(database: db);
    jobs = JobsRepositoryLocal(database: db);

    for (final (id, vehicleId) in const [
      ('j1', 'v1'),
      ('j2', 'v1'),
      ('j3', 'v2'),
    ]) {
      await jobs.addJob(vehicleId, Job(id: id, vehicleId: vehicleId, title: id));
    }
    for (final (id, name) in const [
      ('p1', 'Alpha'),
      ('p2', 'Beta'),
      ('p3', 'Gamma'),
    ]) {
      await parts.addPart(Part(id: id, name: name));
    }

    Future<void> link(String jobId, String partId, int qty, double? cost) =>
        parts.addJobPart(
          JobPart(
            id: '$jobId-$partId',
            jobId: jobId,
            partId: partId,
            quantity: qty,
            unitCost: cost,
          ),
        );

    await link('j1', 'p1', 2, 10); // 20
    await link('j1', 'p2', 1, 5); //  5
    await link('j2', 'p1', 1, 10); // 10
    await link('j2', 'p3', 3, null); // 0 (null unit cost)
    await link('j3', 'p2', 5, 5); // 25 (other vehicle)
  });

  tearDown(() async => db.close());

  test('partsTotalForJob sums a job\'s lines; null unit cost counts as 0',
      () async {
    expect(ok(await parts.partsTotalForJob('j1')), closeTo(25, 1e-9));
    expect(ok(await parts.partsTotalForJob('j2')), closeTo(10, 1e-9));
    expect(ok(await parts.partsTotalForJob('nope')), 0);
  });

  test('partsTotalForVehicle sums across the vehicle\'s jobs only', () async {
    expect(ok(await parts.partsTotalForVehicle('v1')), closeTo(35, 1e-9));
    expect(ok(await parts.partsTotalForVehicle('v2')), closeTo(25, 1e-9));
    expect(ok(await parts.partsTotalForVehicle('v3')), 0);
  });

  test('getPartsForVehicle returns distinct parts, ordered by name', () async {
    final result = ok(await parts.getPartsForVehicle('v1'));
    expect(result.map((p) => p.id), ['p1', 'p2', 'p3']);
  });

  test('getPartsUsageForVehicle aggregates qty + spend, highest spend first',
      () async {
    final usage = ok(await parts.getPartsUsageForVehicle('v1'));
    expect(usage.map((u) => u.part.id), ['p1', 'p2', 'p3']);

    expect(usage[0].totalQuantity, 3); // p1: 2 + 1
    expect(usage[0].totalSpent, closeTo(30, 1e-9)); // 20 + 10
    expect(usage[1].totalSpent, closeTo(5, 1e-9)); // p2, j1 only (not v2)
    expect(usage[2].totalQuantity, 3); // p3
    expect(usage[2].totalSpent, 0); // null unit cost
  });

  test('getJobParts joins each link to its part, oldest first', () async {
    final lines = ok(await parts.getJobParts('j1'));
    expect(lines.map((l) => l.part.id), ['p1', 'p2']);
    expect(lines[0].link.quantity, 2);
    expect(lines[0].part.name, 'Alpha');
    expect(lines[1].link.totalCost, closeTo(5, 1e-9));
  });

  test('getJobs attaches each job\'s photos in one grouped read', () async {
    // Insert photo rows directly (no files needed — getJobs only reads rows).
    await db.insertJobPhoto(
      const JobPhotosCompanion(
        id: Value('ph1'),
        jobId: Value('j1'),
        photoPath: Value('photos/a.jpg'),
      ),
    );
    await db.insertJobPhoto(
      const JobPhotosCompanion(
        id: Value('ph2'),
        jobId: Value('j1'),
        photoPath: Value('photos/b.jpg'),
      ),
    );

    final result = ok(await jobs.getJobs('v1'));
    final j1 = result.firstWhere((j) => j.id == 'j1');
    final j2 = result.firstWhere((j) => j.id == 'j2');
    expect(j1.photoPaths, containsAll(['photos/a.jpg', 'photos/b.jpg']));
    expect(j2.photoPaths, isEmpty);
  });
}

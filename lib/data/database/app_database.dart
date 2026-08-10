import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/vehicles.dart';
import 'tables/jobs.dart';
import 'tables/job_photos.dart';
import 'tables/projects.dart';
import 'tables/parts.dart';
import 'tables/job_parts.dart';
import 'tables/part_photos.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Vehicles, Jobs, JobPhotos, Projects, Parts, JobParts, PartPhotos],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Opens the database against a caller-supplied executor. Used by tests to
  /// run the real schema/migrations on an in-memory SQLite instance
  /// (`NativeDatabase.memory()`) instead of the on-disk `tala.db`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v1 -> v2: the projects grouping (Phase 2, Slice 3). A job belongs to
      // at most one project via the new nullable jobs.projectId column.
      if (from < 2) {
        await m.createTable(projects);
        await m.addColumn(jobs, jobs.projectId);
      }
      // v2 -> v3: parts (Phase 2). A reusable catalogue, linked to jobs via
      // job_parts, with optional photos on the part.
      if (from < 3) {
        await m.createTable(parts);
        await m.createTable(jobParts);
        await m.createTable(partPhotos);
      }
    },
  );

  // Vehicle operations
  Future<List<Vehicle>> getAllVehicles() => select(vehicles).get();

  Stream<List<Vehicle>> watchAllVehicles() => select(vehicles).watch();

  Future<Vehicle?> getVehicleById(String id) =>
      (select(vehicles)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertVehicle(VehiclesCompanion vehicle) =>
      into(vehicles).insert(vehicle);

  Future<bool> updateVehicle(VehiclesCompanion vehicle) =>
      update(vehicles).replace(vehicle);

  Future<int> deleteVehicle(String id) =>
      (delete(vehicles)..where((t) => t.id.equals(id))).go();

  // Job operations
  Future<List<Job>> getJobsForVehicle(String vehicleId) =>
      (select(jobs)
            ..where((t) => t.vehicleId.equals(vehicleId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.startDate,
                mode: OrderingMode.desc,
              ),
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  Stream<List<Job>> watchJobsForVehicle(String vehicleId) =>
      (select(jobs)
            ..where((t) => t.vehicleId.equals(vehicleId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.startDate,
                mode: OrderingMode.desc,
              ),
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  Future<Job?> getJobById(String id) =>
      (select(jobs)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertJob(JobsCompanion job) => into(jobs).insert(job);

  Future<bool> updateJob(JobsCompanion job) => update(jobs).replace(job);

  Future<int> deleteJob(String id) =>
      (delete(jobs)..where((t) => t.id.equals(id))).go();

  Future<int> deleteJobsForVehicle(String vehicleId) =>
      (delete(jobs)..where((t) => t.vehicleId.equals(vehicleId))).go();

  // Job photo operations
  Future<List<JobPhoto>> getPhotosForJob(String jobId) =>
      (select(jobPhotos)..where((t) => t.jobId.equals(jobId))).get();

  Future<int> insertJobPhoto(JobPhotosCompanion photo) =>
      into(jobPhotos).insert(photo);

  Future<int> deleteJobPhoto(String id) =>
      (delete(jobPhotos)..where((t) => t.id.equals(id))).go();

  Future<int> deletePhotosForJob(String jobId) =>
      (delete(jobPhotos)..where((t) => t.jobId.equals(jobId))).go();

  // Project operations
  Future<List<Project>> getProjectsForVehicle(String vehicleId) =>
      (select(projects)
            ..where((t) => t.vehicleId.equals(vehicleId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.startDate,
                mode: OrderingMode.desc,
              ),
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  Future<Project?> getProjectById(String id) =>
      (select(projects)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertProject(ProjectsCompanion project) =>
      into(projects).insert(project);

  Future<bool> updateProject(ProjectsCompanion project) =>
      update(projects).replace(project);

  Future<int> deleteProject(String id) =>
      (delete(projects)..where((t) => t.id.equals(id))).go();

  /// Jobs assigned to a project, newest first (mirrors [getJobsForVehicle]).
  Future<List<Job>> getJobsForProject(String projectId) =>
      (select(jobs)
            ..where((t) => t.projectId.equals(projectId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.startDate,
                mode: OrderingMode.desc,
              ),
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  /// Unassigns every job pointing at [projectId] (sets `project_id` to null).
  /// Used before deleting a project so its jobs survive, unlinked.
  Future<int> clearProjectFromJobs(String projectId) =>
      (update(jobs)..where((t) => t.projectId.equals(projectId))).write(
        JobsCompanion(
          projectId: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );

  // Part (catalogue) operations
  Future<List<Part>> getAllParts() =>
      (select(parts)..orderBy([(t) => OrderingTerm(expression: t.name)])).get();

  Future<Part?> getPartById(String id) =>
      (select(parts)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertPart(PartsCompanion part) => into(parts).insert(part);

  Future<bool> updatePart(PartsCompanion part) => update(parts).replace(part);

  Future<int> deletePart(String id) =>
      (delete(parts)..where((t) => t.id.equals(id))).go();

  // Part photo operations
  Future<List<PartPhoto>> getPhotosForPart(String partId) =>
      (select(partPhotos)..where((t) => t.partId.equals(partId))).get();

  Future<int> insertPartPhoto(PartPhotosCompanion photo) =>
      into(partPhotos).insert(photo);

  Future<int> deletePartPhoto(String id) =>
      (delete(partPhotos)..where((t) => t.id.equals(id))).go();

  Future<int> deletePhotosForPart(String partId) =>
      (delete(partPhotos)..where((t) => t.partId.equals(partId))).go();

  // Job-part (link) operations
  Future<int> insertJobPart(JobPartsCompanion jobPart) =>
      into(jobParts).insert(jobPart);

  Future<bool> updateJobPart(JobPartsCompanion jobPart) =>
      update(jobParts).replace(jobPart);

  Future<int> deleteJobPart(String id) =>
      (delete(jobParts)..where((t) => t.id.equals(id))).go();

  Future<int> deleteJobPartsForJob(String jobId) =>
      (delete(jobParts)..where((t) => t.jobId.equals(jobId))).go();

  Future<int> deleteJobPartsForPart(String partId) =>
      (delete(jobParts)..where((t) => t.partId.equals(partId))).go();

  // --- Joins & aggregates -------------------------------------------------
  // Single-query replacements for what would otherwise be per-row (N+1) loops
  // in the repositories. FKs aren't enforced, but these inner-join through
  // job_parts/jobs, so a link to a deleted part or job simply drops out.

  /// `unit_cost * quantity` for a job_parts row. A null unit cost makes the
  /// product null; SQL `SUM`/`TOTAL` then skip it, matching the domain's
  /// `(unitCost ?? 0) * quantity`.
  Expression<double> get _lineCost =>
      jobParts.unitCost * jobParts.quantity.cast<double>();

  /// Photos for many jobs in one query; the caller groups by [JobPhoto.jobId].
  /// Empty [jobIds] returns an empty list without touching the database.
  Future<List<JobPhoto>> getPhotosForJobs(Iterable<String> jobIds) {
    final ids = jobIds.toList();
    if (ids.isEmpty) return Future.value(const []);
    return (select(jobPhotos)..where((t) => t.jobId.isIn(ids))).get();
  }

  /// A job's parts joined to their catalogue rows, oldest link first.
  Future<List<({JobPart link, Part part})>> getJobPartsWithParts(String jobId) {
    final query = select(jobParts).join([
      innerJoin(parts, parts.id.equalsExp(jobParts.partId)),
    ])
      ..where(jobParts.jobId.equals(jobId))
      ..orderBy([OrderingTerm(expression: jobParts.createdAt)]);
    return query
        .map(
          (row) => (link: row.readTable(jobParts), part: row.readTable(parts)),
        )
        .get();
  }

  /// Distinct parts used on any of [vehicleId]'s jobs, ordered by name.
  Future<List<Part>> getPartsUsedByVehicle(String vehicleId) {
    final query = select(parts).join([
      innerJoin(jobParts, jobParts.partId.equalsExp(parts.id)),
      innerJoin(jobs, jobs.id.equalsExp(jobParts.jobId)),
    ])
      ..where(jobs.vehicleId.equals(vehicleId))
      ..groupBy([parts.id])
      ..orderBy([OrderingTerm(expression: parts.name)]);
    return query.map((row) => row.readTable(parts)).get();
  }

  /// Per-part usage totals (quantity + spend) for [vehicleId], highest spend
  /// first (ties broken by name for a stable order).
  Future<List<({Part part, int totalQuantity, double totalSpent})>>
  getPartsUsageForVehicle(String vehicleId) async {
    final quantity = jobParts.quantity.sum();
    final spent = _lineCost.total();
    final query = select(parts).join([
      innerJoin(jobParts, jobParts.partId.equalsExp(parts.id)),
      innerJoin(jobs, jobs.id.equalsExp(jobParts.jobId)),
    ])
      ..addColumns([quantity, spent])
      ..where(jobs.vehicleId.equals(vehicleId))
      ..groupBy([parts.id])
      ..orderBy([
        OrderingTerm.desc(spent),
        OrderingTerm(expression: parts.name),
      ]);
    final rows = await query.get();
    return [
      for (final row in rows)
        (
          part: row.readTable(parts),
          totalQuantity: row.read(quantity) ?? 0,
          totalSpent: row.read(spent) ?? 0,
        ),
    ];
  }

  /// Total parts spend on a single job.
  Future<double> partsTotalForJob(String jobId) async {
    final total = _lineCost.total();
    final query = selectOnly(jobParts)
      ..addColumns([total])
      ..where(jobParts.jobId.equals(jobId));
    final row = await query.getSingle();
    return row.read(total) ?? 0;
  }

  /// Total parts spend across all of a vehicle's jobs.
  Future<double> partsTotalForVehicle(String vehicleId) async {
    final total = _lineCost.total();
    final query = select(jobParts).join([
      innerJoin(jobs, jobs.id.equalsExp(jobParts.jobId)),
    ])
      ..addColumns([total])
      ..where(jobs.vehicleId.equals(vehicleId));
    final row = await query.getSingle();
    return row.read(total) ?? 0;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tala.db'));
    return NativeDatabase.createInBackground(file);
  });
}
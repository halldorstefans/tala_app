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
  Future<List<JobPart>> getJobPartsForJob(String jobId) =>
      (select(jobParts)
            ..where((t) => t.jobId.equals(jobId))
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .get();

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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tala.db'));
    return NativeDatabase.createInBackground(file);
  });
}
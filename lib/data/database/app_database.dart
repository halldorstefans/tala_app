import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/vehicles.dart';
import 'tables/jobs.dart';
import 'tables/job_photos.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Vehicles, Jobs, JobPhotos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tala.db'));
    return NativeDatabase.createInBackground(file);
  });
}
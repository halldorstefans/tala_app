import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../domain/models/job.dart' as domain;
import '../../../utils/result.dart';
import '../../../utils/app_exception.dart';
import '../../database/app_database.dart' as db;
import 'jobs_repository.dart';

class JobsRepositoryLocal implements JobsRepository {
  JobsRepositoryLocal({required db.AppDatabase database})
      : _database = database;

  final db.AppDatabase _database;
  final _log = Logger('JobsRepositoryLocal');
  final _uuid = const Uuid();

  @override
  Future<Result<domain.Job>> getJob(String vehicleId, String jobId) async {
    try {
      final result = await _database.getJobById(jobId);
      if (result == null || result.vehicleId != vehicleId) {
        return Result.error(const NotFoundException('Job'));
      }

      final photos = await _database.getPhotosForJob(jobId);
      final photoPaths = photos.map((p) => p.photoPath).toList();

      return Result.ok(domain.Job.fromDrift(result, photoPaths: photoPaths));
    } catch (e, st) {
      _log.severe('Exception in getJob', e, st);
      return Result.error(StorageException('Failed to get job', cause: e));
    }
  }

  @override
  Future<Result<List<domain.Job>>> getJobs(String vehicleId) async {
    try {
      final results = await _database.getJobsForVehicle(vehicleId);

      // One query for every job's photos, grouped in memory — rather than a
      // getPhotosForJob round-trip per job (N+1).
      final photos = await _database.getPhotosForJobs(
        results.map((j) => j.id),
      );
      final pathsByJob = <String, List<String>>{};
      for (final photo in photos) {
        (pathsByJob[photo.jobId] ??= <String>[]).add(photo.photoPath);
      }

      final jobs = [
        for (final job in results)
          domain.Job.fromDrift(
            job,
            photoPaths: pathsByJob[job.id] ?? const <String>[],
          ),
      ];
      return Result.ok(jobs);
    } catch (e, st) {
      _log.severe('Exception in getJobs', e, st);
      return Result.error(StorageException('Failed to get jobs', cause: e));
    }
  }

  @override
  Future<Result<String>> addJob(String vehicleId, domain.Job job) async {
    try {
      final id = job.id.isEmpty ? _uuid.v4() : job.id;
      final jobWithId = job.copyWith(id: id, vehicleId: vehicleId);
      await _database.insertJob(jobWithId.toDrift());
      return Result.ok(id);
    } catch (e, st) {
      _log.severe('Exception in addJob', e, st);
      return Result.error(StorageException('Failed to add job', cause: e));
    }
  }

  @override
  Future<Result<domain.Job>> updateJob(String vehicleId, domain.Job job) async {
    try {
      final existing = await _database.getJobById(job.id);
      if (existing == null || existing.vehicleId != vehicleId) {
        return Result.error(const NotFoundException('Job'));
      }

      await _database.updateJob(job.copyWith(vehicleId: vehicleId).toDrift());
      return Result.ok(job);
    } catch (e, st) {
      _log.severe('Exception in updateJob', e, st);
      return Result.error(StorageException('Failed to update job', cause: e));
    }
  }

  @override
  Future<Result<void>> deleteJob(String vehicleId, String jobId) async {
    try {
      // Delete the photo files from disk first, then their rows — a row with no
      // file is recoverable noise, but a file with no row is an unreachable leak
      // that also bloats every backup.
      await _deletePhotoFiles(await _database.getPhotosForJob(jobId));
      await _database.deletePhotosForJob(jobId);
      await _database.deleteJobPartsForJob(jobId);
      await _database.deleteJob(jobId);
      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Exception in deleteJob', e, st);
      return Result.error(StorageException('Failed to delete job', cause: e));
    }
  }

  /// Deletes the on-disk file backing each photo row. Missing files are
  /// tolerated (already gone). Resolves relative paths against the app
  /// documents dir, mirroring how they were stored in [uploadJobPhoto].
  Future<void> _deletePhotoFiles(Iterable<db.JobPhoto> photos) async {
    if (photos.isEmpty) return;
    final dir = await getApplicationDocumentsDirectory();
    for (final photo in photos) {
      final file = File(p.join(dir.path, photo.photoPath));
      if (await file.exists()) await file.delete();
    }
  }

  @override
  Future<Result<String>> uploadJobPhoto(
    String vehicleId,
    String jobId,
    File photo,
  ) async {
    try {
      final job = await _database.getJobById(jobId);
      if (job == null || job.vehicleId != vehicleId) {
        return Result.error(const NotFoundException('Job'));
      }

      final dir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(p.join(dir.path, 'photos'));
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final ext = p.extension(photo.path);
      final photoId = _uuid.v4();
      final newPath = p.join(photosDir.path, '$photoId$ext');

      await photo.copy(newPath);

      final relativePath = p.join('photos', '$photoId$ext');

      await _database.insertJobPhoto(
        db.JobPhotosCompanion(
          id: Value(_uuid.v4()),
          jobId: Value(jobId),
          photoPath: Value(relativePath),
          createdAt: Value(DateTime.now()),
        ),
      );

      return Result.ok(relativePath);
    } catch (e, st) {
      _log.severe('Exception in uploadJobPhoto', e, st);
      return Result.error(StorageException('Failed to upload job photo', cause: e));
    }
  }

  @override
  Future<Result<void>> deleteJobPhoto(
    String vehicleId,
    String jobId,
    String photoPath,
  ) async {
    try {
      final photos = await _database.getPhotosForJob(jobId);
      final photo = photos.where((p) => p.photoPath == photoPath).firstOrNull;
      if (photo == null) {
        return Result.error(const NotFoundException('Photo'));
      }

      final dir = await getApplicationDocumentsDirectory();
      final fullPath = p.join(dir.path, photo.photoPath);
      final file = File(fullPath);
      if (await file.exists()) {
        await file.delete();
      }

      await _database.deleteJobPhoto(photo.id);
      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Exception in deleteJobPhoto', e, st);
      return Result.error(StorageException('Failed to delete job photo', cause: e));
    }
  }
}
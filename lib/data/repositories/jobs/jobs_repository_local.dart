import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../domain/models/job.dart' as domain;
import '../../../utils/result.dart';
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
        return Result.error(Exception('Job not found'));
      }

      final photos = await _database.getPhotosForJob(jobId);
      final photoPaths = photos.map((p) => p.photoPath).toList();

      return Result.ok(domain.Job.fromDrift(result, photoPaths: photoPaths));
    } catch (e, st) {
      _log.severe('Exception in getJob', e, st);
      return Result.error(Exception('Failed to get job'));
    }
  }

  @override
  Future<Result<List<domain.Job>>> getJobs(String vehicleId) async {
    try {
      final results = await _database.getJobsForVehicle(vehicleId);
      final jobs = <domain.Job>[];
      for (final job in results) {
        final photos = await _database.getPhotosForJob(job.id);
        final photoPaths = photos.map((p) => p.photoPath).toList();
        jobs.add(domain.Job.fromDrift(job, photoPaths: photoPaths));
      }
      return Result.ok(jobs);
    } catch (e, st) {
      _log.severe('Exception in getJobs', e, st);
      return Result.error(Exception('Failed to get jobs'));
    }
  }

  @override
  Future<Result<String>> addJob(String vehicleId, domain.Job job) async {
    try {
      final id = job.id.isEmpty ? _uuid.v4() : job.id;
      final jobWithId = domain.Job(
        id: id,
        vehicleId: vehicleId,
        title: job.title,
        startDate: job.startDate,
        completionDate: job.completionDate,
        odometer: job.odometer,
        category: job.category,
        status: job.status,
        description: job.description,
        cost: job.cost,
        photoPaths: job.photoPaths,
      );
      await _database.insertJob(jobWithId.toDrift());
      return Result.ok(id);
    } catch (e, st) {
      _log.severe('Exception in addJob', e, st);
      return Result.error(Exception('Failed to add job'));
    }
  }

  @override
  Future<Result<domain.Job>> updateJob(String vehicleId, domain.Job job) async {
    try {
      final existing = await _database.getJobById(job.id);
      if (existing == null || existing.vehicleId != vehicleId) {
        return Result.error(Exception('Job not found'));
      }

      final updatedAt = DateTime.now();

      await _database.updateJob(
        db.JobsCompanion(
          id: Value(job.id),
          vehicleId: Value(vehicleId),
          title: Value(job.title),
          startDate: Value(job.startDate),
          completionDate: Value(job.completionDate),
          odometer: Value(job.odometer),
          category: Value(job.category),
          status: Value(job.status),
          description: Value(job.description),
          cost: Value(job.cost),
          createdAt: Value(existing.createdAt),
          updatedAt: Value(updatedAt),
        ),
      );

      return Result.ok(job);
    } catch (e, st) {
      _log.severe('Exception in updateJob', e, st);
      return Result.error(Exception('Failed to update job'));
    }
  }

  @override
  Future<Result<void>> deleteJob(String vehicleId, String jobId) async {
    try {
      await _database.deletePhotosForJob(jobId);
      await _database.deleteJob(jobId);
      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Exception in deleteJob', e, st);
      return Result.error(Exception('Failed to delete job'));
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
        return Result.error(Exception('Job not found'));
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
      return Result.error(Exception('Failed to upload job photo'));
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
        return Result.error(Exception('Photo not found'));
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
      return Result.error(Exception('Failed to delete job photo'));
    }
  }
}
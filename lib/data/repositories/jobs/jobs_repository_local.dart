import 'dart:io';

import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/attachment.dart' as domain;
import '../../../domain/models/attachment_type.dart' as domain;
import '../../../domain/models/job.dart' as domain;
import '../../../utils/result.dart';
import '../../../utils/app_exception.dart';
import '../../database/app_database.dart' as db;
import '../../services/attachment_storage.dart';
import 'jobs_repository.dart';

class JobsRepositoryLocal implements JobsRepository {
  JobsRepositoryLocal({required db.AppDatabase database})
      : _database = database;

  final db.AppDatabase _database;
  final _log = Logger('JobsRepositoryLocal');
  final _uuid = const Uuid();
  final _storage = const AttachmentStorage();

  /// The storage paths of a job's *photo* attachments (ignoring receipts,
  /// documents, etc.), which is what the job UI still consumes as `photoPaths`.
  List<String> _photoPaths(Iterable<db.Attachment> attachments) => [
        for (final a in attachments)
          if (a.type == domain.AttachmentType.photo.wire) a.storagePath,
      ];

  @override
  Future<Result<domain.Job>> getJob(String vehicleId, String jobId) async {
    try {
      final result = await _database.getJobById(jobId);
      if (result == null || result.vehicleId != vehicleId) {
        return Result.error(const NotFoundException('Job'));
      }

      final attachments = await _database.getAttachmentsForJob(jobId);
      return Result.ok(
        domain.Job.fromDrift(result, photoPaths: _photoPaths(attachments)),
      );
    } catch (e, st) {
      _log.severe('Exception in getJob', e, st);
      return Result.error(StorageException('Failed to get job', cause: e));
    }
  }

  @override
  Future<Result<List<domain.Job>>> getJobs(String vehicleId) async {
    try {
      final results = await _database.getJobsForVehicle(vehicleId);

      // One query for every job's attachments, grouped in memory — rather than
      // a getAttachmentsForJob round-trip per job (N+1).
      final attachments = await _database.getAttachmentsForJobs(
        results.map((j) => j.id),
      );
      final pathsByJob = <String, List<String>>{};
      for (final a in attachments) {
        final jobId = a.jobId;
        if (jobId == null || a.type != domain.AttachmentType.photo.wire) {
          continue;
        }
        (pathsByJob[jobId] ??= <String>[]).add(a.storagePath);
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
      // Delete the attachment files from disk first, then their rows — a row
      // with no file is recoverable noise, but a file with no row is an
      // unreachable leak that also bloats every backup.
      final attachments = await _database.getAttachmentsForJob(jobId);
      await _storage.deleteAll(attachments.map((a) => a.storagePath));
      await _database.deleteAttachmentsForJob(jobId);
      await _database.deleteJobPartsForJob(jobId);
      await _database.deleteJob(jobId);
      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Exception in deleteJob', e, st);
      return Result.error(StorageException('Failed to delete job', cause: e));
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

      final relativePath = await _storage.save(photo);
      final attachment = domain.Attachment(
        id: _uuid.v4(),
        type: domain.AttachmentType.photo,
        storagePath: relativePath,
        jobId: jobId,
      );
      await _database.insertAttachment(attachment.toDrift());

      return Result.ok(relativePath);
    } catch (e, st) {
      _log.severe('Exception in uploadJobPhoto', e, st);
      return Result.error(
        StorageException('Failed to upload job photo', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> deleteJobPhoto(
    String vehicleId,
    String jobId,
    String photoPath,
  ) async {
    try {
      final attachments = await _database.getAttachmentsForJob(jobId);
      final attachment =
          attachments.where((a) => a.storagePath == photoPath).firstOrNull;
      if (attachment == null) {
        return Result.error(const NotFoundException('Photo'));
      }

      await _storage.delete(attachment.storagePath);
      await _database.deleteAttachment(attachment.id);
      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Exception in deleteJobPhoto', e, st);
      return Result.error(
        StorageException('Failed to delete job photo', cause: e),
      );
    }
  }
}

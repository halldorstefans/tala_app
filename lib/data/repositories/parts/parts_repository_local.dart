import 'dart:io';

import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/attachment.dart' as domain;
import '../../../domain/models/attachment_type.dart' as domain;
import '../../../domain/models/job_part.dart' as domain;
import '../../../domain/models/part.dart' as domain;
import '../../../utils/result.dart';
import '../../../utils/app_exception.dart';
import '../../database/app_database.dart' as db;
import '../../services/attachment_storage.dart';
import 'parts_repository.dart';

class PartsRepositoryLocal implements PartsRepository {
  PartsRepositoryLocal({required db.AppDatabase database})
    : _database = database;

  final db.AppDatabase _database;
  final _log = Logger('PartsRepositoryLocal');
  final _uuid = const Uuid();
  final _storage = const AttachmentStorage();

  @override
  Future<Result<List<domain.Part>>> getParts() async {
    try {
      final rows = await _database.getAllParts();
      return Result.ok(rows.map((r) => domain.Part.fromDrift(r)).toList());
    } catch (e, st) {
      _log.severe('Exception in getParts', e, st);
      return Result.error(StorageException('Failed to get parts', cause: e));
    }
  }

  @override
  Future<Result<domain.Part>> getPart(String partId) async {
    try {
      final row = await _database.getPartById(partId);
      if (row == null) return Result.error(const NotFoundException('Part'));
      return Result.ok(domain.Part.fromDrift(row));
    } catch (e, st) {
      _log.severe('Exception in getPart', e, st);
      return Result.error(StorageException('Failed to get part', cause: e));
    }
  }

  @override
  Future<Result<String>> addPart(domain.Part part) async {
    try {
      final id = part.id.isEmpty ? _uuid.v4() : part.id;
      await _database.insertPart(part.copyWith(id: id).toDrift());
      return Result.ok(id);
    } catch (e, st) {
      _log.severe('Exception in addPart', e, st);
      return Result.error(StorageException('Failed to add part', cause: e));
    }
  }

  @override
  Future<Result<domain.Part>> updatePart(domain.Part part) async {
    try {
      final existing = await _database.getPartById(part.id);
      if (existing == null) return Result.error(const NotFoundException('Part'));
      await _database.updatePart(part.toDrift());
      return Result.ok(part);
    } catch (e, st) {
      _log.severe('Exception in updatePart', e, st);
      return Result.error(StorageException('Failed to update part', cause: e));
    }
  }

  @override
  Future<Result<void>> deletePart(String partId) async {
    try {
      // Remove usages first (no FK enforcement — manual cascade), then the
      // attachment files + rows, then the part itself.
      await _database.deleteJobPartsForPart(partId);

      final attachments = await _database.getAttachmentsForPart(partId);
      await _storage.deleteAll(attachments.map((a) => a.storagePath));
      await _database.deleteAttachmentsForPart(partId);

      await _database.deletePart(partId);
      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Exception in deletePart', e, st);
      return Result.error(StorageException('Failed to delete part', cause: e));
    }
  }

  @override
  Future<Result<String>> uploadPartPhoto(String partId, File photo) async {
    try {
      final part = await _database.getPartById(partId);
      if (part == null) return Result.error(const NotFoundException('Part'));

      final relativePath = await _storage.save(photo);
      final attachment = domain.Attachment(
        id: _uuid.v4(),
        type: domain.AttachmentType.photo,
        storagePath: relativePath,
        partId: partId,
      );
      await _database.insertAttachment(attachment.toDrift());
      return Result.ok(relativePath);
    } catch (e, st) {
      _log.severe('Exception in uploadPartPhoto', e, st);
      return Result.error(StorageException('Failed to upload part photo', cause: e));
    }
  }

  @override
  Future<Result<List<domain.JobPartLine>>> getJobParts(String jobId) async {
    try {
      final rows = await _database.getJobPartsWithParts(jobId);
      return Result.ok([
        for (final row in rows)
          (
            link: domain.JobPart.fromDrift(row.link),
            part: domain.Part.fromDrift(row.part),
          ),
      ]);
    } catch (e, st) {
      _log.severe('Exception in getJobParts', e, st);
      return Result.error(StorageException('Failed to get job parts', cause: e));
    }
  }

  @override
  Future<Result<String>> addJobPart(domain.JobPart jobPart) async {
    try {
      final id = jobPart.id.isEmpty ? _uuid.v4() : jobPart.id;
      await _database.insertJobPart(jobPart.copyWith(id: id).toDrift());
      return Result.ok(id);
    } catch (e, st) {
      _log.severe('Exception in addJobPart', e, st);
      return Result.error(StorageException('Failed to add job part', cause: e));
    }
  }

  @override
  Future<Result<domain.JobPart>> updateJobPart(domain.JobPart jobPart) async {
    try {
      await _database.updateJobPart(jobPart.toDrift());
      return Result.ok(jobPart);
    } catch (e, st) {
      _log.severe('Exception in updateJobPart', e, st);
      return Result.error(StorageException('Failed to update job part', cause: e));
    }
  }

  @override
  Future<Result<void>> deleteJobPart(String jobPartId) async {
    try {
      await _database.deleteJobPart(jobPartId);
      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Exception in deleteJobPart', e, st);
      return Result.error(StorageException('Failed to delete job part', cause: e));
    }
  }

  @override
  Future<Result<List<domain.Part>>> getPartsForVehicle(String vehicleId) async {
    try {
      final rows = await _database.getPartsUsedByVehicle(vehicleId);
      return Result.ok([for (final row in rows) domain.Part.fromDrift(row)]);
    } catch (e, st) {
      _log.severe('Exception in getPartsForVehicle', e, st);
      return Result.error(StorageException('Failed to get parts for vehicle', cause: e));
    }
  }

  @override
  Future<Result<List<domain.PartUsage>>> getPartsUsageForVehicle(
    String vehicleId,
  ) async {
    try {
      final rows = await _database.getPartsUsageForVehicle(vehicleId);
      return Result.ok([
        for (final row in rows)
          (
            part: domain.Part.fromDrift(row.part),
            totalQuantity: row.totalQuantity,
            totalSpent: row.totalSpent,
          ),
      ]);
    } catch (e, st) {
      _log.severe('Exception in getPartsUsageForVehicle', e, st);
      return Result.error(StorageException('Failed to get parts usage for vehicle', cause: e));
    }
  }

  @override
  Future<Result<double>> partsTotalForJob(String jobId) async {
    try {
      return Result.ok(await _database.partsTotalForJob(jobId));
    } catch (e, st) {
      _log.severe('Exception in partsTotalForJob', e, st);
      return Result.error(StorageException('Failed to total job parts', cause: e));
    }
  }

  @override
  Future<Result<double>> partsTotalForVehicle(String vehicleId) async {
    try {
      return Result.ok(await _database.partsTotalForVehicle(vehicleId));
    } catch (e, st) {
      _log.severe('Exception in partsTotalForVehicle', e, st);
      return Result.error(StorageException('Failed to total vehicle parts', cause: e));
    }
  }
}

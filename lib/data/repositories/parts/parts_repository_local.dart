import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../domain/models/job_part.dart' as domain;
import '../../../domain/models/part.dart' as domain;
import '../../../utils/result.dart';
import '../../database/app_database.dart' as db;
import 'parts_repository.dart';

class PartsRepositoryLocal implements PartsRepository {
  PartsRepositoryLocal({required db.AppDatabase database})
    : _database = database;

  final db.AppDatabase _database;
  final _log = Logger('PartsRepositoryLocal');
  final _uuid = const Uuid();

  @override
  Future<Result<List<domain.Part>>> getParts() async {
    try {
      final rows = await _database.getAllParts();
      return Result.ok(rows.map((r) => domain.Part.fromDrift(r)).toList());
    } catch (e, st) {
      _log.severe('Exception in getParts', e, st);
      return Result.error(Exception('Failed to get parts'));
    }
  }

  @override
  Future<Result<domain.Part>> getPart(String partId) async {
    try {
      final row = await _database.getPartById(partId);
      if (row == null) return Result.error(Exception('Part not found'));
      final photos = await _database.getPhotosForPart(partId);
      return Result.ok(
        domain.Part.fromDrift(
          row,
          photoPaths: photos.map((ph) => ph.photoPath).toList(),
        ),
      );
    } catch (e, st) {
      _log.severe('Exception in getPart', e, st);
      return Result.error(Exception('Failed to get part'));
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
      return Result.error(Exception('Failed to add part'));
    }
  }

  @override
  Future<Result<domain.Part>> updatePart(domain.Part part) async {
    try {
      final existing = await _database.getPartById(part.id);
      if (existing == null) return Result.error(Exception('Part not found'));
      await _database.updatePart(part.toDrift());
      return Result.ok(part);
    } catch (e, st) {
      _log.severe('Exception in updatePart', e, st);
      return Result.error(Exception('Failed to update part'));
    }
  }

  @override
  Future<Result<void>> deletePart(String partId) async {
    try {
      // Remove usages first (no FK enforcement — manual cascade), then the
      // photo files + rows, then the part itself.
      await _database.deleteJobPartsForPart(partId);

      final photos = await _database.getPhotosForPart(partId);
      final dir = await getApplicationDocumentsDirectory();
      for (final photo in photos) {
        final file = File(p.join(dir.path, photo.photoPath));
        if (await file.exists()) await file.delete();
      }
      await _database.deletePhotosForPart(partId);

      await _database.deletePart(partId);
      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Exception in deletePart', e, st);
      return Result.error(Exception('Failed to delete part'));
    }
  }

  @override
  Future<Result<String>> uploadPartPhoto(String partId, File photo) async {
    try {
      final part = await _database.getPartById(partId);
      if (part == null) return Result.error(Exception('Part not found'));

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

      await _database.insertPartPhoto(
        db.PartPhotosCompanion(
          id: Value(_uuid.v4()),
          partId: Value(partId),
          photoPath: Value(relativePath),
          createdAt: Value(DateTime.now()),
        ),
      );
      return Result.ok(relativePath);
    } catch (e, st) {
      _log.severe('Exception in uploadPartPhoto', e, st);
      return Result.error(Exception('Failed to upload part photo'));
    }
  }

  @override
  Future<Result<void>> deletePartPhoto(String partId, String photoPath) async {
    try {
      final photos = await _database.getPhotosForPart(partId);
      final photo = photos.where((ph) => ph.photoPath == photoPath).firstOrNull;
      if (photo == null) return Result.error(Exception('Photo not found'));

      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, photo.photoPath));
      if (await file.exists()) await file.delete();

      await _database.deletePartPhoto(photo.id);
      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Exception in deletePartPhoto', e, st);
      return Result.error(Exception('Failed to delete part photo'));
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
      return Result.error(Exception('Failed to get job parts'));
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
      return Result.error(Exception('Failed to add job part'));
    }
  }

  @override
  Future<Result<domain.JobPart>> updateJobPart(domain.JobPart jobPart) async {
    try {
      await _database.updateJobPart(jobPart.toDrift());
      return Result.ok(jobPart);
    } catch (e, st) {
      _log.severe('Exception in updateJobPart', e, st);
      return Result.error(Exception('Failed to update job part'));
    }
  }

  @override
  Future<Result<void>> deleteJobPart(String jobPartId) async {
    try {
      await _database.deleteJobPart(jobPartId);
      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Exception in deleteJobPart', e, st);
      return Result.error(Exception('Failed to delete job part'));
    }
  }

  @override
  Future<Result<List<domain.Part>>> getPartsForVehicle(String vehicleId) async {
    try {
      final rows = await _database.getPartsUsedByVehicle(vehicleId);
      return Result.ok([for (final row in rows) domain.Part.fromDrift(row)]);
    } catch (e, st) {
      _log.severe('Exception in getPartsForVehicle', e, st);
      return Result.error(Exception('Failed to get parts for vehicle'));
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
      return Result.error(Exception('Failed to get parts usage for vehicle'));
    }
  }

  @override
  Future<Result<double>> partsTotalForJob(String jobId) async {
    try {
      return Result.ok(await _database.partsTotalForJob(jobId));
    } catch (e, st) {
      _log.severe('Exception in partsTotalForJob', e, st);
      return Result.error(Exception('Failed to total job parts'));
    }
  }

  @override
  Future<Result<double>> partsTotalForVehicle(String vehicleId) async {
    try {
      return Result.ok(await _database.partsTotalForVehicle(vehicleId));
    } catch (e, st) {
      _log.severe('Exception in partsTotalForVehicle', e, st);
      return Result.error(Exception('Failed to total vehicle parts'));
    }
  }
}

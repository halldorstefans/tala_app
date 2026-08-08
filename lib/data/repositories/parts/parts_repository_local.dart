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
      final links = await _database.getJobPartsForJob(jobId);
      final lines = <domain.JobPartLine>[];
      for (final link in links) {
        final partRow = await _database.getPartById(link.partId);
        if (partRow == null) continue; // link to a deleted part; skip
        lines.add((
          link: domain.JobPart.fromDrift(link),
          part: domain.Part.fromDrift(partRow),
        ));
      }
      return Result.ok(lines);
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
      final jobs = await _database.getJobsForVehicle(vehicleId);
      final seen = <String>{};
      final result = <domain.Part>[];
      for (final job in jobs) {
        final links = await _database.getJobPartsForJob(job.id);
        for (final link in links) {
          if (!seen.add(link.partId)) continue;
          final partRow = await _database.getPartById(link.partId);
          if (partRow != null) result.add(domain.Part.fromDrift(partRow));
        }
      }
      return Result.ok(result);
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
      final jobs = await _database.getJobsForVehicle(vehicleId);
      final quantities = <String, int>{};
      final spent = <String, double>{};
      for (final job in jobs) {
        for (final link in await _database.getJobPartsForJob(job.id)) {
          quantities[link.partId] =
              (quantities[link.partId] ?? 0) + link.quantity;
          spent[link.partId] =
              (spent[link.partId] ?? 0) + (link.unitCost ?? 0) * link.quantity;
        }
      }

      final usages = <domain.PartUsage>[];
      for (final partId in quantities.keys) {
        final partRow = await _database.getPartById(partId);
        if (partRow == null) continue;
        usages.add((
          part: domain.Part.fromDrift(partRow),
          totalQuantity: quantities[partId]!,
          totalSpent: spent[partId] ?? 0,
        ));
      }
      usages.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
      return Result.ok(usages);
    } catch (e, st) {
      _log.severe('Exception in getPartsUsageForVehicle', e, st);
      return Result.error(Exception('Failed to get parts usage for vehicle'));
    }
  }

  @override
  Future<Result<double>> partsTotalForJob(String jobId) async {
    try {
      final links = await _database.getJobPartsForJob(jobId);
      final total = links.fold<double>(
        0,
        (sum, l) => sum + (l.unitCost ?? 0) * l.quantity,
      );
      return Result.ok(total);
    } catch (e, st) {
      _log.severe('Exception in partsTotalForJob', e, st);
      return Result.error(Exception('Failed to total job parts'));
    }
  }

  @override
  Future<Result<double>> partsTotalForVehicle(String vehicleId) async {
    try {
      final jobs = await _database.getJobsForVehicle(vehicleId);
      var total = 0.0;
      for (final job in jobs) {
        final links = await _database.getJobPartsForJob(job.id);
        total += links.fold<double>(
          0,
          (sum, l) => sum + (l.unitCost ?? 0) * l.quantity,
        );
      }
      return Result.ok(total);
    } catch (e, st) {
      _log.severe('Exception in partsTotalForVehicle', e, st);
      return Result.error(Exception('Failed to total vehicle parts'));
    }
  }
}

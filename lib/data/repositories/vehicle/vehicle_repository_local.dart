import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../domain/models/vehicle.dart' as domain;
import '../../../utils/result.dart';
import '../../database/app_database.dart' as db;
import 'vehicle_repository.dart';

class VehicleRepositoryLocal implements VehicleRepository {
  VehicleRepositoryLocal({required db.AppDatabase database})
      : _database = database;

  final db.AppDatabase _database;
  final _log = Logger('VehicleRepositoryLocal');
  final _uuid = const Uuid();

  @override
  Future<Result<domain.Vehicle>> getVehicle(String vehicleId) async {
    try {
      final result = await _database.getVehicleById(vehicleId);
      if (result == null) {
        return Result.error(Exception('Vehicle not found'));
      }
      return Result.ok(domain.Vehicle.fromDrift(result));
    } catch (e, st) {
      _log.severe('Exception in getVehicle', e, st);
      return Result.error(Exception('Failed to get vehicle'));
    }
  }

  @override
  Future<Result<List<domain.Vehicle>>> getVehicles() async {
    try {
      final results = await _database.getAllVehicles();
      final vehicles = results.map((v) => domain.Vehicle.fromDrift(v)).toList();
      return Result.ok(vehicles);
    } catch (e, st) {
      _log.severe('Exception in getVehicles', e, st);
      return Result.error(Exception('Failed to get vehicles'));
    }
  }

  @override
  Future<Result<String>> addVehicle(domain.Vehicle vehicle) async {
    try {
      final id = vehicle.id.isEmpty ? _uuid.v4() : vehicle.id;
      final vehicleWithId = vehicle.copyWith(id: id);
      await _database.insertVehicle(vehicleWithId.toDrift());
      return Result.ok(id);
    } catch (e, st) {
      _log.severe('Exception in addVehicle', e, st);
      return Result.error(Exception('Failed to add vehicle'));
    }
  }

  @override
  Future<Result<domain.Vehicle>> updateVehicle(domain.Vehicle vehicle) async {
    try {
      final existing = await _database.getVehicleById(vehicle.id);
      if (existing == null) {
        return Result.error(Exception('Vehicle not found'));
      }

      await _database.updateVehicle(vehicle.toDrift());
      return Result.ok(vehicle);
    } catch (e, st) {
      _log.severe('Exception in updateVehicle', e, st);
      return Result.error(Exception('Failed to update vehicle'));
    }
  }

  @override
  Future<Result<void>> deleteVehicle(String vehicleId) async {
    try {
      final jobs = await _database.getJobsForVehicle(vehicleId);
      for (final job in jobs) {
        await _database.deletePhotosForJob(job.id);
        await _database.deleteJobPartsForJob(job.id);
      }
      await _database.deleteJobsForVehicle(vehicleId);
      await _database.deleteVehicle(vehicleId);
      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Exception in deleteVehicle', e, st);
      return Result.error(Exception('Failed to delete vehicle'));
    }
  }

  @override
  Future<Result<String>> uploadVehiclePhoto(String vehicleId, File photo) async {
    try {
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

      final existing = await _database.getVehicleById(vehicleId);
      if (existing == null) {
        await File(newPath).delete();
        return Result.error(Exception('Vehicle not found'));
      }

      final vehicle = domain.Vehicle.fromDrift(existing)
          .copyWith(photoPath: relativePath);
      await _database.updateVehicle(vehicle.toDrift());

      return Result.ok(relativePath);
    } catch (e, st) {
      _log.severe('Exception in uploadVehiclePhoto', e, st);
      return Result.error(Exception('Failed to upload vehicle photo'));
    }
  }
}
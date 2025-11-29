import 'dart:io';

import 'package:logging/logging.dart';

import '/data/models/vehicle_api_model.dart';
import '/domain/models/vehicle.dart';
import '../../../utils/result.dart';
import '../../services/tala_api/api_client.dart';
import 'vehicle_repository.dart';

class VehicleRepositoryRemote extends VehicleRepository {
  VehicleRepositoryRemote({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  final _log = Logger('VehicleRepositoryRemote');

  @override
  Future<Result<Vehicle>> getVehicle(String vehicleId) async {
    try {
      final response = await _apiClient.getVehicle(vehicleId);
      switch (response) {
        case Ok<VehicleApiModel>():
          final vehicle = Vehicle(
            id: response.value.id,
            make: response.value.make,
            model: response.value.model,
            year: response.value.year,
            nickname: response.value.nickname,
            registration: response.value.registrationNumber,
            vin: response.value.vin,
            colour: response.value.colour,
            odometer: response.value.odometer,
            purchaseDate: response.value.purchaseDate,
            notes: response.value.notes,
            photoUrl: response.value.photoUrl,
          );

          return Result.ok(vehicle);
        case Error<VehicleApiModel>():
          _log.warning('Failed to get vehicle $vehicleId', response.error);
          return Result.error(response.error);
      }
    } catch (e, st) {
      _log.severe('Exception in getVehicle', e, st);
      return Result.error(Exception('Failed to get vehicle'));
    }
  }

  @override
  Future<Result<List<Vehicle>>> getVehicles() async {
    try {
      final response = await _apiClient.getVehicles();
      switch (response) {
        case Ok<List<VehicleApiModel>>():
          if (response.value.isEmpty) {
            return Result.ok([]);
          }
          final vehicles = response.value
              .map(
                (apiModel) => Vehicle(
                  id: apiModel.id,
                  make: apiModel.make,
                  model: apiModel.model,
                  year: apiModel.year,
                  nickname: apiModel.nickname,
                  registration: apiModel.registrationNumber,
                  vin: apiModel.vin,
                  colour: apiModel.colour,
                  odometer: apiModel.odometer,
                  purchaseDate: apiModel.purchaseDate,
                  notes: apiModel.notes,
                  photoUrl: apiModel.photoUrl,
                ),
              )
              .toList();
          return Result.ok(vehicles);
        case Error<List<VehicleApiModel>>():
          _log.warning('Failed to get vehicles', response.error);
          return Result.error(Exception('Failed to get vehicles'));
      }
    } catch (e, st) {
      _log.severe('Exception in getVehicles', e, st);
      return Result.error(Exception('Failed to get vehicles'));
    }
  }

  @override
  Future<Result<void>> addVehicle(Vehicle vehicle) async {
    try {
      final vehicleApiModel = VehicleApiModel(
        id: vehicle.id,
        make: vehicle.make,
        model: vehicle.model,
        year: vehicle.year,
        registrationNumber: vehicle.registration,
        vin: vehicle.vin,
        colour: vehicle.colour,
        odometer: vehicle.odometer,
        nickname: vehicle.nickname,
        purchaseDate: vehicle.purchaseDate,
        notes: vehicle.notes,
        photoUrl: vehicle.photoUrl,
      );
      final response = await _apiClient.addVehicle(vehicleApiModel);
      switch (response) {
        case Ok<void>():
          return Result.ok(null);
        case Error<void>():
          _log.warning('Failed to add vehicle', response.error);
          return Result.error(response.error);
      }
    } catch (e, st) {
      _log.severe('Exception in addVehicle', e, st);
      return Result.error(Exception('Failed to add vehicle'));
    }
  }

  @override
  Future<Result<Vehicle>> updateVehicle(Vehicle vehicle) async {
    try {
      final vehicleApiModel = VehicleApiModel(
        id: vehicle.id,
        make: vehicle.make,
        model: vehicle.model,
        year: vehicle.year,
        registrationNumber: vehicle.registration,
        vin: vehicle.vin,
        colour: vehicle.colour,
        odometer: vehicle.odometer,
        nickname: vehicle.nickname,
        purchaseDate: vehicle.purchaseDate,
        notes: vehicle.notes,
        photoUrl: vehicle.photoUrl,
      );
      final response = await _apiClient.updateVehicle(vehicleApiModel);
      switch (response) {
        case Ok<VehicleApiModel>():
          final updatedVehicle = Vehicle(
            id: response.value.id,
            make: response.value.make,
            model: response.value.model,
            year: response.value.year,
            nickname: response.value.nickname,
            registration: response.value.registrationNumber,
            vin: response.value.vin,
            colour: response.value.colour,
            odometer: response.value.odometer,
            purchaseDate: response.value.purchaseDate,
            notes: response.value.notes,
            photoUrl: response.value.photoUrl,
          );
          return Result.ok(updatedVehicle);
        case Error<VehicleApiModel>():
          _log.warning('Failed to update vehicle', response.error);
          return Result.error(response.error);
      }
    } catch (e, st) {
      _log.severe('Exception in updateVehicle', e, st);
      return Result.error(Exception('Failed to update vehicle'));
    }
  }

  @override
  Future<Result<void>> deleteVehicle(String vehicleId) async {
    try {
      final response = await _apiClient.deleteVehicle(vehicleId);
      switch (response) {
        case Ok<void>():
          return Result.ok(null);
        case Error<void>():
          _log.warning('Failed to delete vehicle', response.error);
          return Result.error(response.error);
      }
    } catch (e, st) {
      _log.severe('Exception in deleteVehicle', e, st);
      return Result.error(Exception('Failed to delete vehicle'));
    }
  }

  @override
  Future<Result<String>> uploadVehiclePhoto(
    String vehicleId,
    File photo,
  ) async {
    try {
      final response = await _apiClient.uploadVehiclePhoto(vehicleId, photo);
      switch (response) {
        case Ok<String>():
          return Result.ok(response.value);
        case Error<String>():
          _log.warning('Failed to upload vehicle photo', response.error);
          return Result.error(response.error);
      }
    } catch (e, st) {
      _log.severe('Exception in uploadVehiclePhoto', e, st);
      return Result.error(Exception('Failed to upload vehicle photo'));
    }
  }
}

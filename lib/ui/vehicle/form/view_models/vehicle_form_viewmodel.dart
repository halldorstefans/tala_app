import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../../../../data/repositories/vehicle/vehicle_repository.dart';
import '../../../../domain/models/vehicle.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';

class VehicleFormViewmodel extends ChangeNotifier {
  VehicleFormViewmodel({
    required VehicleRepository vehicleRepository,
    Vehicle? vehicle,
  }) : _vehicle = vehicle,
       _vehicleRepository = vehicleRepository {
    addVehicle = Command1(_addVehicle);
    updateVehicle = Command1(_updateVehicle);
    fetchVehicle = Command1(_fetchVehicle);
  }

  final _log = Logger('VehicleFormViewModel');
  final VehicleRepository _vehicleRepository;

  Vehicle? _vehicle;
  Vehicle? get vehicle => _vehicle;

  late final Command1<void, Vehicle> addVehicle;
  late final Command1<void, Vehicle> updateVehicle;
  late final Command1<void, String> fetchVehicle;

  Future<Result<void>> _addVehicle(Vehicle vehicle) async {
    final result = await _vehicleRepository.addVehicle(vehicle);

    switch (result) {
      case Error<void>():
        _log.severe('Error adding vehicle: ${result.error}');
        return result;
      case Ok<void>():
    }

    _vehicle = vehicle;

    notifyListeners();

    return result;
  }

  Future<Result<void>> _updateVehicle(Vehicle vehicle) async {
    final result = await _vehicleRepository.updateVehicle(vehicle);

    switch (result) {
      case Error<Vehicle>():
        _log.severe('Error updating vehicle: ${result.error}');
        return result;
      case Ok<Vehicle>():
    }

    _vehicle = vehicle;

    notifyListeners();

    return result;
  }

  Future<Result<void>> _fetchVehicle(String vehicleId) async {
    final result = await _vehicleRepository.getVehicle(vehicleId);

    switch (result) {
      case Error<Vehicle>():
        _log.severe('Error fetching vehicles: ${result.error}');
        return result;
      case Ok<Vehicle>():
    }

    _vehicle = result.value;

    notifyListeners();

    return result;
  }

  Future<Result<String>> uploadVehiclePhoto(
    String vehicleId,
    File photoFile,
  ) async {
    final result = await _vehicleRepository.uploadVehiclePhoto(
      vehicleId,
      photoFile,
    );

    switch (result) {
      case Error<String>():
        _log.severe('Error uploading vehicle photo: ${result.error}');
        return result;
      case Ok<String>():
    }

    notifyListeners();

    return result;
  }
}

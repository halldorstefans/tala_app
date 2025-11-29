import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:tala_app/data/repositories/vehicle/vehicle_repository.dart';

import '../../../domain/models/vehicle.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required VehicleRepository vehicleRepository})
    : _vehicleRepository = vehicleRepository {
    fetchVehicles = Command0(_fetchVehicles)..execute();
  }

  final _log = Logger('HomeViewModel');
  final VehicleRepository _vehicleRepository;

  final List<Vehicle> _vehicles = <Vehicle>[];
  List<Vehicle> get vehicles => _vehicles;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  late Command0 fetchVehicles;

  Future<Result<void>> _fetchVehicles() async {
    final result = await _vehicleRepository.getVehicles();

    switch (result) {
      case Error<List<Vehicle>>():
        _log.severe('Error fetching vehicles: ${result.error}');
        _errorMessage = result.error.toString();
        return result;
      case Ok<List<Vehicle>>():
    }

    _vehicles.addAll(result.value);

    return result;
  }
}

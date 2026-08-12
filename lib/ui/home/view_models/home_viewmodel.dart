import 'dart:async';

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
    // Keep the list live: adding, editing, or deleting a vehicle from anywhere
    // re-emits, so the home screen no longer needs a manual refetch (or a
    // restart) to reflect the change.
    _subscription = _vehicleRepository.watchVehicles().listen(
      (vehicles) {
        _vehicles
          ..clear()
          ..addAll(vehicles);
        notifyListeners();
      },
      onError: (Object e, StackTrace st) =>
          _log.warning('Vehicle watch stream error', e, st),
    );
  }

  final _log = Logger('HomeViewModel');
  final VehicleRepository _vehicleRepository;

  final List<Vehicle> _vehicles = <Vehicle>[];
  List<Vehicle> get vehicles => _vehicles;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  late Command0 fetchVehicles;
  StreamSubscription<List<Vehicle>>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<Result<void>> _fetchVehicles() async {
    final result = await _vehicleRepository.getVehicles();

    switch (result) {
      case Error<List<Vehicle>>():
        _log.severe('Error fetching vehicles: ${result.error}');
        _errorMessage = result.error.toString();
        notifyListeners();
        return result;
      case Ok<List<Vehicle>>():
    }

    _vehicles
      ..clear()
      ..addAll(result.value);
    notifyListeners();

    return result;
  }
}

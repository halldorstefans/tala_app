import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../data/repositories/parts/parts_repository.dart';
import '../../../../domain/models/job_part.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';

/// Parts used across a single vehicle's jobs, each with total quantity and
/// total spent.
class PartsUsedViewModel extends ChangeNotifier {
  PartsUsedViewModel({
    required PartsRepository partsRepository,
    required String vehicleId,
  }) : _partsRepository = partsRepository,
       _vehicleId = vehicleId {
    fetchUsage = Command1(_fetchUsage)..execute(vehicleId);
  }

  final _log = Logger('PartsUsedViewModel');
  final PartsRepository _partsRepository;

  final String _vehicleId;
  String get vehicleId => _vehicleId;

  final List<PartUsage> _usage = <PartUsage>[];
  List<PartUsage> get usage => _usage;

  /// Total spent on parts across the vehicle.
  double get grandTotal =>
      _usage.fold<double>(0, (sum, u) => sum + u.totalSpent);

  late Command1<void, String> fetchUsage;

  Future<Result<void>> _fetchUsage(String vehicleId) async {
    final result = await _partsRepository.getPartsUsageForVehicle(vehicleId);
    switch (result) {
      case Error<List<PartUsage>>():
        _log.severe('Error fetching parts usage: ${result.error}');
        return result;
      case Ok<List<PartUsage>>():
    }
    _usage
      ..clear()
      ..addAll(result.value);
    notifyListeners();
    return const Result.ok(null);
  }
}

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../data/repositories/parts/parts_repository.dart';
import '../../../../domain/models/part.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';

/// Edits a part's catalogue fields. Photos are managed on the part detail
/// screen, so this form is fields-only. Creating a part happens inline via the
/// add-part sheet, so there is no add path here.
class PartFormViewModel extends ChangeNotifier {
  PartFormViewModel({required PartsRepository partsRepository, Part? part})
    : _partsRepository = partsRepository,
      _part = part {
    updatePart = Command1(_updatePart);
    fetchPart = Command1(_fetchPart);
  }

  final _log = Logger('PartFormViewModel');
  final PartsRepository _partsRepository;

  Part? _part;
  Part? get part => _part;

  late final Command1<void, Part> updatePart;
  late final Command1<void, String> fetchPart;

  Future<Result<void>> _fetchPart(String partId) async {
    final result = await _partsRepository.getPart(partId);
    switch (result) {
      case Error<Part>():
        _log.severe('Error fetching part: ${result.error}');
        return result;
      case Ok<Part>():
        _part = result.value;
    }
    notifyListeners();
    return const Result.ok(null);
  }

  Future<Result<void>> _updatePart(Part part) async {
    final result = await _partsRepository.updatePart(part);
    switch (result) {
      case Error<Part>():
        _log.severe('Error updating part: ${result.error}');
        return result;
      case Ok<Part>():
    }
    _part = part;
    notifyListeners();
    return const Result.ok(null);
  }
}

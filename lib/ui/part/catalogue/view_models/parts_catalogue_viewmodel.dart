import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../data/repositories/parts/parts_repository.dart';
import '../../../../domain/models/part.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';

/// The global parts catalogue: every part, searchable by name / part number.
class PartsCatalogueViewModel extends ChangeNotifier {
  PartsCatalogueViewModel({required PartsRepository partsRepository})
    : _partsRepository = partsRepository {
    fetchParts = Command0(_fetchParts)..execute();
  }

  final _log = Logger('PartsCatalogueViewModel');
  final PartsRepository _partsRepository;

  final List<Part> _parts = <Part>[];
  String _query = '';
  String get query => _query;

  /// Parts matching the current query (name or part number), or all when the
  /// query is blank.
  List<Part> get filteredParts {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(_parts);
    return _parts
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              (p.partNumber?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  bool get isEmpty => _parts.isEmpty;

  late final Command0<void> fetchParts;

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<Result<void>> _fetchParts() async {
    final result = await _partsRepository.getParts();
    switch (result) {
      case Error<List<Part>>():
        _log.severe('Error fetching parts: ${result.error}');
        return result;
      case Ok<List<Part>>():
    }
    _parts
      ..clear()
      ..addAll(result.value);
    notifyListeners();
    return const Result.ok(null);
  }
}

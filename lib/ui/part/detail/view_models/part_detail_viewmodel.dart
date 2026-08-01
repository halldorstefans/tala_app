import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../data/repositories/parts/parts_repository.dart';
import '../../../../domain/models/part.dart';
import '../../../../utils/command.dart';
import '../../../../utils/photo_compressor.dart';
import '../../../../utils/result.dart';

class PartDetailViewModel extends ChangeNotifier {
  PartDetailViewModel({
    required PartsRepository partsRepository,
    PhotoCompressor? compressor,
  }) : _partsRepository = partsRepository,
       _compressor = compressor ?? defaultPhotoCompressor {
    load = Command1<void, String>(_load);
    delete = Command0(_delete);
  }

  final _log = Logger('PartDetailViewModel');
  final PartsRepository _partsRepository;
  final PhotoCompressor _compressor;

  String? _partId;
  String? get partId => _partId;

  Part? _part;
  Part? get part => _part;

  late final Command1<void, String> load;
  late final Command0<void> delete;

  Future<Result<void>> _load(String partId) async {
    _partId = partId;
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

  Future<Result<void>> addPhoto(File photo) async {
    final id = _partId;
    if (id == null) return Result.error(Exception('No part loaded'));
    final compressed = await _compressor(photo) ?? photo;
    final result = await _partsRepository.uploadPartPhoto(id, compressed);
    if (result is Error<String>) {
      _log.severe('Error adding part photo: ${result.error}');
      return result;
    }
    return _load(id);
  }

  Future<Result<void>> deletePhoto(String photoPath) async {
    final id = _partId;
    if (id == null) return Result.error(Exception('No part loaded'));
    final result = await _partsRepository.deletePartPhoto(id, photoPath);
    if (result is Error<void>) {
      _log.severe('Error deleting part photo: ${result.error}');
      return result;
    }
    return _load(id);
  }

  Future<Result<void>> _delete() async {
    final id = _partId;
    if (id == null) return Result.error(Exception('No part loaded'));
    final result = await _partsRepository.deletePart(id);
    if (result is Error<void>) {
      _log.severe('Error deleting part: ${result.error}');
    }
    return result;
  }
}

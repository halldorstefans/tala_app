import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../data/repositories/attachments/attachments_repository.dart';
import '../../../../domain/models/attachment.dart';
import '../../../../domain/models/attachment_type.dart';
import '../../../../utils/command.dart';
import '../../../../utils/file_types.dart';
import '../../../../utils/photo_compressor.dart';
import '../../../../utils/result.dart';

/// Backs the reusable [AttachmentsSection]. Owns the attachment list for a
/// single owner (a vehicle, project, job, or part) and the commands to load,
/// add, re-caption, and delete. Reusable across every owner because ownership
/// is hidden behind [AttachmentOwner].
class AttachmentsViewModel extends ChangeNotifier {
  AttachmentsViewModel({
    required AttachmentsRepository repository,
    required AttachmentOwner owner,
    PhotoCompressor? compressor,
  }) : _repository = repository,
       _owner = owner,
       _compressor = compressor ?? defaultPhotoCompressor {
    load = Command0(_load)..execute();
    addPhoto = Command1(_addPhoto);
    addPhotos = Command1(_addPhotos);
    updateCaption = Command1(_updateCaption);
    remove = Command1(_remove);
  }

  final _log = Logger('AttachmentsViewModel');
  final AttachmentsRepository _repository;
  final AttachmentOwner _owner;
  final PhotoCompressor _compressor;

  final List<Attachment> _attachments = [];
  List<Attachment> get attachments => List.unmodifiable(_attachments);

  late final Command0<void> load;
  late final Command1<void, ({File file, AttachmentType type, String? caption})>
  addPhoto;

  /// Bulk-add: several images at once, all of one [AttachmentType] and without
  /// captions (which can be added later per item). Reloads once at the end.
  late final Command1<void, ({List<File> files, AttachmentType type})>
  addPhotos;
  late final Command1<void, ({String id, String? caption})> updateCaption;
  late final Command1<void, String> remove;

  Future<Result<void>> _load() async {
    final result = await _repository.getFor(_owner);
    switch (result) {
      case Error<List<Attachment>>():
        _log.severe('Error loading attachments: ${result.error}');
        return result;
      case Ok<List<Attachment>>():
        _attachments
          ..clear()
          ..addAll(result.value);
        notifyListeners();
        return const Result.ok(null);
    }
  }

  Future<Result<void>> _addPhoto(
    ({File file, AttachmentType type, String? caption}) args,
  ) async {
    final result = await _repository.add(
      _owner,
      file: await _maybeCompress(args.file),
      type: args.type,
      caption: args.caption,
    );
    switch (result) {
      case Error<Attachment>():
        _log.severe('Error adding attachment: ${result.error}');
        return result;
      case Ok<Attachment>():
        return _load();
    }
  }

  Future<Result<void>> _addPhotos(
    ({List<File> files, AttachmentType type}) args,
  ) async {
    for (final file in args.files) {
      final result = await _repository.add(
        _owner,
        file: await _maybeCompress(file),
        type: args.type,
      );
      if (result case Error<Attachment>()) {
        _log.severe('Error adding attachment: ${result.error}');
        await _load();
        return result;
      }
    }
    return _load();
  }

  /// Compresses images before storing; passes documents (PDFs, etc.) through
  /// untouched — the compressor is JPEG-only and asserts on anything else.
  Future<File> _maybeCompress(File file) async {
    if (!isImagePath(file.path)) return file;
    return await _compressor(file) ?? file;
  }

  Future<Result<void>> _updateCaption(
    ({String id, String? caption}) args,
  ) async {
    final result = await _repository.updateCaption(args.id, args.caption);
    if (result is Ok<void>) return _load();
    _log.severe('Error updating caption: ${(result as Error).error}');
    return result;
  }

  Future<Result<void>> _remove(String id) async {
    final result = await _repository.delete(id);
    if (result is Ok<void>) return _load();
    _log.severe('Error deleting attachment: ${(result as Error).error}');
    return result;
  }
}

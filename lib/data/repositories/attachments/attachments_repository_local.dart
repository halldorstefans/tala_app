import 'dart:io';

import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/attachment.dart' as domain;
import '../../../domain/models/attachment_type.dart' as domain;
import '../../../utils/app_exception.dart';
import '../../../utils/result.dart';
import '../../database/app_database.dart' as db;
import '../../services/attachment_storage.dart';
import 'attachments_repository.dart';

class AttachmentsRepositoryLocal implements AttachmentsRepository {
  AttachmentsRepositoryLocal({required db.AppDatabase database})
    : _database = database;

  final db.AppDatabase _database;
  final _log = Logger('AttachmentsRepositoryLocal');
  final _uuid = const Uuid();
  final _storage = const AttachmentStorage();

  @override
  Future<Result<List<domain.Attachment>>> getFor(AttachmentOwner owner) async {
    try {
      final rows = switch (owner.kind) {
        AttachmentOwnerKind.vehicle => await _database.getAttachmentsForVehicle(
          owner.id,
        ),
        AttachmentOwnerKind.project => await _database.getAttachmentsForProject(
          owner.id,
        ),
        AttachmentOwnerKind.job => await _database.getAttachmentsForJob(
          owner.id,
        ),
        AttachmentOwnerKind.part => await _database.getAttachmentsForPart(
          owner.id,
        ),
      };
      return Result.ok([
        for (final row in rows) domain.Attachment.fromDrift(row),
      ]);
    } catch (e, st) {
      _log.severe('Exception in getFor', e, st);
      return Result.error(StorageException('Failed to get attachments', cause: e));
    }
  }

  @override
  Future<Result<domain.Attachment>> add(
    AttachmentOwner owner, {
    required File file,
    required domain.AttachmentType type,
    String? caption,
  }) async {
    String? savedPath;
    try {
      savedPath = await _storage.save(file);
      final attachment = domain.Attachment(
        id: _uuid.v4(),
        type: type,
        storagePath: savedPath,
        caption: caption,
        vehicleId: owner.kind == AttachmentOwnerKind.vehicle ? owner.id : null,
        projectId: owner.kind == AttachmentOwnerKind.project ? owner.id : null,
        jobId: owner.kind == AttachmentOwnerKind.job ? owner.id : null,
        partId: owner.kind == AttachmentOwnerKind.part ? owner.id : null,
      );
      await _database.insertAttachment(attachment.toDrift());
      return Result.ok(attachment);
    } catch (e, st) {
      _log.severe('Exception in add', e, st);
      // Don't leave the copied file orphaned if the row insert failed.
      if (savedPath != null) await _storage.delete(savedPath);
      return Result.error(StorageException('Failed to add attachment', cause: e));
    }
  }

  @override
  Future<Result<void>> updateCaption(String id, String? caption) async {
    try {
      await _database.updateAttachmentCaption(id, caption);
      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Exception in updateCaption', e, st);
      return Result.error(
        StorageException('Failed to update caption', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      final row = await _database.getAttachmentById(id);
      if (row == null) return Result.error(const NotFoundException('Attachment'));
      await _storage.delete(row.storagePath);
      await _database.deleteAttachment(id);
      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Exception in delete', e, st);
      return Result.error(
        StorageException('Failed to delete attachment', cause: e),
      );
    }
  }
}

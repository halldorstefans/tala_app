import 'dart:io';

import 'package:tala_app/data/repositories/attachments/attachments_repository.dart';
import 'package:tala_app/domain/models/attachment.dart';
import 'package:tala_app/domain/models/attachment_type.dart';
import 'package:tala_app/utils/result.dart';

class FakeAttachmentsRepository implements AttachmentsRepository {
  final List<Attachment> attachments = [];
  Exception? error;
  String nextId = 'att-1';

  Attachment? lastAdded;
  final List<File> uploadedFiles = [];
  String? lastDeleted;
  (String, String?)? lastCaptionUpdate;

  void seed(Attachment attachment) => attachments.add(attachment);

  bool _ownedBy(Attachment a, AttachmentOwner owner) => switch (owner.kind) {
    AttachmentOwnerKind.vehicle => a.vehicleId == owner.id,
    AttachmentOwnerKind.project => a.projectId == owner.id,
    AttachmentOwnerKind.job => a.jobId == owner.id,
    AttachmentOwnerKind.part => a.partId == owner.id,
  };

  @override
  Future<Result<List<Attachment>>> getFor(AttachmentOwner owner) async {
    if (error != null) return Result.error(error!);
    return Result.ok(attachments.where((a) => _ownedBy(a, owner)).toList());
  }

  @override
  Future<Result<Attachment>> add(
    AttachmentOwner owner, {
    required File file,
    required AttachmentType type,
    String? caption,
  }) async {
    if (error != null) return Result.error(error!);
    uploadedFiles.add(file);
    final attachment = Attachment(
      id: nextId,
      type: type,
      storagePath: 'photos/$nextId.jpg',
      caption: caption,
      vehicleId: owner.kind == AttachmentOwnerKind.vehicle ? owner.id : null,
      projectId: owner.kind == AttachmentOwnerKind.project ? owner.id : null,
      jobId: owner.kind == AttachmentOwnerKind.job ? owner.id : null,
      partId: owner.kind == AttachmentOwnerKind.part ? owner.id : null,
    );
    lastAdded = attachment;
    attachments.add(attachment);
    return Result.ok(attachment);
  }

  @override
  Future<Result<void>> updateCaption(String id, String? caption) async {
    if (error != null) return Result.error(error!);
    lastCaptionUpdate = (id, caption);
    final i = attachments.indexWhere((a) => a.id == id);
    if (i >= 0) attachments[i] = attachments[i].copyWith(caption: caption);
    return Result.ok(null);
  }

  @override
  Future<Result<void>> delete(String id) async {
    if (error != null) return Result.error(error!);
    lastDeleted = id;
    attachments.removeWhere((a) => a.id == id);
    return Result.ok(null);
  }
}

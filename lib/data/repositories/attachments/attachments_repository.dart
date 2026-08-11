import 'dart:io';

import '../../../domain/models/attachment.dart';
import '../../../domain/models/attachment_type.dart';
import '../../../utils/result.dart';

/// Which entity an attachment hangs off. Keeps the repository's callers from
/// having to know that ownership is four nullable columns on one table.
enum AttachmentOwnerKind { vehicle, project, job, part }

class AttachmentOwner {
  const AttachmentOwner.vehicle(this.id) : kind = AttachmentOwnerKind.vehicle;
  const AttachmentOwner.project(this.id) : kind = AttachmentOwnerKind.project;
  const AttachmentOwner.job(this.id) : kind = AttachmentOwnerKind.job;
  const AttachmentOwner.part(this.id) : kind = AttachmentOwnerKind.part;

  final AttachmentOwnerKind kind;
  final String id;
}

/// CRUD over [Attachment]s and the files behind them. The owner-specific columns
/// and the on-disk plumbing live here so ViewModels just deal in [Attachment]s.
abstract class AttachmentsRepository {
  Future<Result<List<Attachment>>> getFor(AttachmentOwner owner);

  /// Saves [file] to disk and records an attachment of [type] owned by [owner].
  Future<Result<Attachment>> add(
    AttachmentOwner owner, {
    required File file,
    required AttachmentType type,
    String? caption,
  });

  Future<Result<void>> updateCaption(String id, String? caption);

  /// Deletes the attachment and its file.
  Future<Result<void>> delete(String id);
}

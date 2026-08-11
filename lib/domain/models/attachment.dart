import 'package:drift/drift.dart' hide Column;

import 'package:tala_app/data/database/app_database.dart' as db;

import 'attachment_type.dart';

/// A file attached to a vehicle, project, job, or part. See the `attachments`
/// table for the ownership rules. [storagePath] is the relative on-disk path
/// (`photos/<uuid>.<ext>`); resolve it with `ApiConfig.getLocalPhotoPath`.
class Attachment {
  final String id;
  final AttachmentType type;
  final String storagePath;
  final String? caption;
  final String? vehicleId;
  final String? projectId;
  final String? jobId;
  final String? partId;

  const Attachment({
    required this.id,
    required this.type,
    required this.storagePath,
    this.caption,
    this.vehicleId,
    this.projectId,
    this.jobId,
    this.partId,
  });

  Attachment copyWith({
    String? id,
    AttachmentType? type,
    String? storagePath,
    String? caption,
    String? vehicleId,
    String? projectId,
    String? jobId,
    String? partId,
  }) {
    return Attachment(
      id: id ?? this.id,
      type: type ?? this.type,
      storagePath: storagePath ?? this.storagePath,
      caption: caption ?? this.caption,
      vehicleId: vehicleId ?? this.vehicleId,
      projectId: projectId ?? this.projectId,
      jobId: jobId ?? this.jobId,
      partId: partId ?? this.partId,
    );
  }

  /// Builds a Companion for insert or update. See [Vehicle.toDrift] for the
  /// rationale on omitting `createdAt`.
  db.AttachmentsCompanion toDrift() {
    return db.AttachmentsCompanion(
      id: Value(id),
      type: Value(type.wire),
      storagePath: Value(storagePath),
      caption: Value(caption),
      vehicleId: Value(vehicleId),
      projectId: Value(projectId),
      jobId: Value(jobId),
      partId: Value(partId),
      updatedAt: Value(DateTime.now()),
    );
  }

  static Attachment fromDrift(db.Attachment data) {
    return Attachment(
      id: data.id,
      type: AttachmentType.fromWire(data.type),
      storagePath: data.storagePath,
      caption: data.caption,
      vehicleId: data.vehicleId,
      projectId: data.projectId,
      jobId: data.jobId,
      partId: data.partId,
    );
  }
}

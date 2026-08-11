/// The kind of file an [Attachment] holds. Stored as [wire] in the database;
/// [label] is for display. Same parse-at-the-boundary pattern as
/// [ProgressStatus]: unknown/null wire values map to [AttachmentType.other].
enum AttachmentType {
  photo('photo', 'Photo'),
  receipt('receipt', 'Receipt'),
  document('document', 'Document'),
  other('other', 'Other');

  const AttachmentType(this.wire, this.label);

  /// The value persisted to SQLite.
  final String wire;

  /// The label shown in the UI.
  final String label;

  /// Parses a stored [wire] value. Falls back to [AttachmentType.other] for
  /// null or any unrecognized string, so a legacy/unknown row still surfaces.
  static AttachmentType fromWire(String? value) {
    for (final type in values) {
      if (type.wire == value) return type;
    }
    return AttachmentType.other;
  }
}

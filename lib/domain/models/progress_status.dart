/// The lifecycle status shared by both jobs and projects:
/// planned → in progress → completed.
///
/// Stored in the database and JSON as [wire] — a value kept deliberately
/// separate from the Dart identifier so renaming a case (or the enum) never
/// rewrites persisted data. [label] is the human-readable display form.
///
/// This is the "parse, don't validate" boundary: a raw string crosses into the
/// app exactly once, at [fromWire], and everything past that point holds a
/// `ProgressStatus` the compiler can reason about exhaustively.
enum ProgressStatus {
  planned('planned', 'Planned'),
  inProgress('in_progress', 'In progress'),
  completed('completed', 'Completed');

  const ProgressStatus(this.wire, this.label);

  /// The value persisted to SQLite / JSON.
  final String wire;

  /// The label shown in the UI.
  final String label;

  /// Parses a stored [wire] value into a status. Returns `null` for `null` or
  /// any unrecognized string (e.g. legacy data) — rendered as "Unknown".
  static ProgressStatus? fromWire(String? value) {
    if (value == null) return null;
    for (final status in values) {
      if (status.wire == value) return status;
    }
    return null;
  }
}

/// Display label for a possibly-null/unknown status.
String statusLabel(ProgressStatus? status) => status?.label ?? 'Unknown';

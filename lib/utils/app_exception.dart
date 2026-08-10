/// Base type for the failures the data layer surfaces through [Result.error].
///
/// Every error a repository or service returns is one of these, so callers and
/// tests can branch on the *kind* of failure (`is NotFoundException`) instead
/// of matching a message string. [toString] is just [message], so it reads
/// cleanly if it ever reaches the UI; the underlying [cause] — a SQLite or
/// filesystem exception — is preserved for logging/diagnostics rather than
/// being discarded at the boundary.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  /// Human-readable summary, safe to show to a user.
  final String message;

  /// The original error that triggered this, when there is one. Null for
  /// deliberate outcomes like "not found".
  final Object? cause;

  @override
  String toString() => message;
}

/// A requested record (or its photo) doesn't exist. Built from the entity name
/// so the message reads "Job not found", "Photo not found", etc.
final class NotFoundException extends AppException {
  const NotFoundException(String entity) : super('$entity not found');
}

/// A storage operation (SQLite or the filesystem) failed unexpectedly.
/// [cause] holds the original exception.
final class StorageException extends AppException {
  const StorageException(super.message, {super.cause});
}

/// Input failed a precondition — e.g. a picked file that isn't a valid backup.
final class ValidationException extends AppException {
  const ValidationException(super.message);
}

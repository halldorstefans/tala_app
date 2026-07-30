import '../../../utils/result.dart';

/// Produces a portable backup of all local data. Local-first safety net: a
/// broken phone shouldn't cost months of restoration logs.
abstract class BackupService {
  /// Creates a backup archive — a ZIP holding a consistent copy of the
  /// database plus the photos directory — in a temporary location, and
  /// returns the absolute path to that archive (for the caller to share).
  Future<Result<String>> createBackup();

  /// Validates and unpacks the backup at [zipPath] into a staging area. The
  /// restore is *not* applied here — the live database can't be swapped out
  /// from under an open connection. [applyPendingRestore] moves the staged
  /// files into place on the next launch, so the caller should prompt the
  /// user to restart the app after this succeeds.
  Future<Result<void>> stageRestore(String zipPath);
}

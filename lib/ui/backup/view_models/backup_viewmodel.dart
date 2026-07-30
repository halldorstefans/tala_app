import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../data/services/backup/backup_service.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class BackupViewModel extends ChangeNotifier {
  BackupViewModel({required BackupService backupService})
    : _backupService = backupService {
    createBackup = Command0(_createBackup);
    stageRestore = Command1(_stageRestore);
  }

  final _log = Logger('BackupViewModel');
  final BackupService _backupService;

  /// Produces the backup archive; the result value is the file path for the
  /// screen to hand to the OS share sheet.
  late final Command0<String> createBackup;

  /// Stages a restore from a picked backup zip. On success the screen prompts
  /// the user to restart so [applyPendingRestore] can finish the job.
  late final Command1<void, String> stageRestore;

  Future<Result<String>> _createBackup() async {
    final result = await _backupService.createBackup();
    if (result is Error<String>) {
      _log.severe('Backup failed: ${result.error}');
    }
    return result;
  }

  Future<Result<void>> _stageRestore(String zipPath) async {
    final result = await _backupService.stageRestore(zipPath);
    if (result is Error<void>) {
      _log.severe('Restore staging failed: ${result.error}');
    }
    return result;
  }
}

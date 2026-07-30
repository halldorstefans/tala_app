import 'package:tala_app/data/services/backup/backup_service.dart';
import 'package:tala_app/utils/result.dart';

class FakeBackupService implements BackupService {
  Exception? error;
  String path = '/tmp/tala-backup.zip';
  int createCount = 0;

  Exception? restoreError;
  String? lastRestorePath;

  @override
  Future<Result<String>> createBackup() async {
    createCount++;
    if (error != null) return Result.error(error!);
    return Result.ok(path);
  }

  @override
  Future<Result<void>> stageRestore(String zipPath) async {
    lastRestorePath = zipPath;
    if (restoreError != null) return Result.error(restoreError!);
    return Result.ok(null);
  }
}

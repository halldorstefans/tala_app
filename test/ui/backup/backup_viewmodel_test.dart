import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/ui/backup/view_models/backup_viewmodel.dart';
import 'package:tala_app/utils/result.dart';

import '../../helpers/fake_backup_service.dart';

void main() {
  group('BackupViewModel', () {
    test('createBackup returns the archive path on success', () async {
      final service = FakeBackupService()..path = '/tmp/backup-123.zip';
      final vm = BackupViewModel(backupService: service);

      await vm.createBackup.execute();

      expect(vm.createBackup.completed, isTrue);
      expect(service.createCount, 1);
      final result = vm.createBackup.result;
      expect(result, isA<Ok<String>>());
      expect((result as Ok<String>).value, '/tmp/backup-123.zip');
    });

    test('createBackup surfaces an error', () async {
      final service = FakeBackupService()..error = Exception('disk full');
      final vm = BackupViewModel(backupService: service);

      await vm.createBackup.execute();

      expect(vm.createBackup.error, isTrue);
    });

    test('stageRestore forwards the picked path to the service', () async {
      final service = FakeBackupService();
      final vm = BackupViewModel(backupService: service);

      await vm.stageRestore.execute('/tmp/picked-backup.zip');

      expect(vm.stageRestore.completed, isTrue);
      expect(service.lastRestorePath, '/tmp/picked-backup.zip');
    });

    test('stageRestore surfaces an error', () async {
      final service = FakeBackupService()
        ..restoreError = Exception('not a tala backup');
      final vm = BackupViewModel(backupService: service);

      await vm.stageRestore.execute('/tmp/bad.zip');

      expect(vm.stageRestore.error, isTrue);
    });
  });
}

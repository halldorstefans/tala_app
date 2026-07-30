import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/ui/backup/view_models/backup_viewmodel.dart';
import 'package:tala_app/ui/backup/widgets/backup_screen.dart';

import '../../helpers/fake_backup_service.dart';

void main() {
  testWidgets('BackupScreen renders the info and back-up button', (
    tester,
  ) async {
    final vm = BackupViewModel(backupService: FakeBackupService());

    await tester.pumpWidget(
      MaterialApp(home: BackupScreen(viewModel: vm)),
    );

    expect(find.text('Back up your logbook'), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, 'Back up now'),
      findsOneWidget,
    );
    expect(find.text('Restore from a backup'), findsOneWidget);
    expect(
      find.widgetWithText(OutlinedButton, 'Restore from backup…'),
      findsOneWidget,
    );
  });
}

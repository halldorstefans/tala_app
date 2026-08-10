import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../../utils/result.dart';
import '../view_models/backup_viewmodel.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key, required this.viewModel});

  final BackupViewModel viewModel;

  Future<void> _backUpNow(BuildContext context) async {
    await viewModel.createBackup.execute();
    if (!context.mounted) return;

    final result = viewModel.createBackup.result;
    if (result is! Ok<String>) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup failed')),
      );
      return;
    }

    // Hand the archive to the OS share sheet so it can be saved to Files,
    // Seafile, Drive, email, etc.
    //
    // The temp file is already named tala-backup-<timestamp>.zip, but that name
    // has to be carried across the share intent deliberately. Two targets, two
    // behaviours: some name the saved file after the shared file (cross_file
    // ignores XFile.name on mobile, so it must come from fileNameOverrides),
    // others after the subject (appending the extension). Give both the
    // timestamped name so every export stays unique either way.
    final fileName = p.basename(result.value);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(result.value, mimeType: 'application/zip')],
        fileNameOverrides: [fileName],
        subject: p.basenameWithoutExtension(result.value),
      ),
    );
  }

  Future<void> _restore(BuildContext context) async {
    final picked = await openFile();
    final path = picked?.path;
    if (path == null) return; // cancelled
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore from backup?'),
        content: const Text(
          'This replaces all current vehicles, jobs, projects, and photos with '
          'the contents of the backup. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    await viewModel.stageRestore.execute(path);
    if (!context.mounted) return;

    if (viewModel.stageRestore.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restore failed — is this a Tala backup?')),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore ready'),
        content: const Text(
          'Fully close Tala and reopen it to finish restoring.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Close app'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Back up your logbook', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Creates a single archive with your full database and all '
              'photos, then opens the share sheet so you can save it wherever '
              'you like — Seafile, Drive, Files, or email. Do this regularly: '
              'a lost or broken phone otherwise takes your restoration logs '
              'with it.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: viewModel.createBackup,
              builder: (context, _) {
                final running = viewModel.createBackup.running;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: running ? null : () => _backUpNow(context),
                    icon: running
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.backup),
                    label: Text(running ? 'Preparing backup…' : 'Back up now'),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            Text('Restore from a backup', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Replaces everything currently in the app with a backup archive. '
              'The app must be restarted to finish. Use this on a new phone, or '
              'to roll back to an earlier backup.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: viewModel.stageRestore,
              builder: (context, _) {
                final running = viewModel.stageRestore.running;
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: running ? null : () => _restore(context),
                    icon: running
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.settings_backup_restore),
                    label: Text(
                      running ? 'Preparing restore…' : 'Restore from backup…',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

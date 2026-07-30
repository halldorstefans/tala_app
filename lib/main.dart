import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'config/dependencies.dart';
import 'data/services/backup/backup_service_local.dart';
import 'routing/router.dart';
import 'ui/core/themes/garage_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL;

  // Apply a staged restore (if any) before the database is first opened —
  // the swap can't happen under a live connection.
  await applyPendingRestore();

  runApp(MultiProvider(providers: providersLocal, child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tala Car Logbook',
      theme: garageTheme,
      routerConfig: router(),
    );
  }
}

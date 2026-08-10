import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/database/app_database.dart';
import '../data/repositories/jobs/jobs_repository_local.dart';
import '../data/repositories/jobs/jobs_repository.dart';
import '../data/repositories/parts/parts_repository_local.dart';
import '../data/repositories/parts/parts_repository.dart';
import '../data/repositories/projects/projects_repository_local.dart';
import '../data/repositories/projects/projects_repository.dart';
import '../data/repositories/vehicle/vehicle_repository_local.dart';
import '../data/repositories/vehicle/vehicle_repository.dart';
import '../data/services/backup/backup_service.dart';
import '../data/services/backup/backup_service_local.dart';
import '../data/services/shared_preferences_service.dart';

/// The active dependency graph: local-first, SQLite-backed. A remote/sync
/// implementation is a future (Phase 4) concern and is intentionally absent —
/// see BACKLOG.md.
List<SingleChildWidget> get providersLocal {
  return [
    Provider(create: (context) => SharedPreferencesService()),
    Provider(create: (context) => AppDatabase()),
    Provider(
      create: (context) =>
          VehicleRepositoryLocal(database: context.read())
              as VehicleRepository,
    ),
    Provider(
      create: (context) =>
          JobsRepositoryLocal(database: context.read()) as JobsRepository,
    ),
    Provider(
      create: (context) =>
          ProjectsRepositoryLocal(database: context.read())
              as ProjectsRepository,
    ),
    Provider(
      create: (context) =>
          PartsRepositoryLocal(database: context.read()) as PartsRepository,
    ),
    Provider(
      create: (context) =>
          BackupServiceLocal(database: context.read()) as BackupService,
    ),
  ];
}

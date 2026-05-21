import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/database/app_database.dart';
import '../data/repositories/auth/auth_repository_local.dart';
import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/jobs/jobs_repository_local.dart';
import '../data/repositories/jobs/jobs_repository.dart';
import '../data/repositories/vehicle/vehicle_repository_local.dart';
import '../data/repositories/vehicle/vehicle_repository.dart';
import '../data/services/shared_preferences_service.dart';
import '../data/services/tala_api/api_client.dart';

List<SingleChildWidget> get providersLocal {
  return [
    Provider(create: (context) => SharedPreferencesService()),
    Provider(create: (context) => AppDatabase()),
    ChangeNotifierProvider(
      create: (context) =>
          AuthRepositoryLocal(
                sharedPreferencesService: context.read(),
              )
              as AuthRepository,
    ),
    Provider(
      create: (context) =>
          VehicleRepositoryLocal(database: context.read())
              as VehicleRepository,
    ),
    Provider(
      create: (context) =>
          JobsRepositoryLocal(database: context.read()) as JobsRepository,
    ),
  ];
}

List<SingleChildWidget> get providersRemote {
  return [
    Provider(create: (context) => ApiClient()),
    Provider(create: (context) => SharedPreferencesService()),
    ChangeNotifierProvider(
      create: (context) => throw UnimplementedError('Use providersLocal or implement AuthRepositoryRemote for sync'),
    ),
    Provider(
      create: (context) => throw UnimplementedError('Use providersLocal or implement VehicleRepositoryRemote for sync'),
    ),
    Provider(
      create: (context) => throw UnimplementedError('Use providersLocal or implement JobsRepositoryRemote for sync'),
    ),
  ];
}

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/auth/auth_repository_local.dart';
import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/jobs/jobs_repository_remote.dart';
import '../data/repositories/jobs/jobs_repository.dart';
import '../data/repositories/vehicle/vehicle_repository_remote.dart';
import '../data/repositories/vehicle/vehicle_repository.dart';
import '../data/services/shared_preferences_service.dart';
import '../data/services/tala_api/api_client.dart';
import '../data/services/tala_api/auth_api_client.dart';

List<SingleChildWidget> get providersLocal {
  return [
    Provider(create: (context) => SharedPreferencesService()),
    Provider(create: (context) => ApiClient()),
    ChangeNotifierProvider(
      create: (context) =>
          AuthRepositoryLocal(
                sharedPreferencesService: context.read(),
              )
              as AuthRepository,
    ),
    Provider(
      create: (context) =>
          VehicleRepositoryRemote(apiClient: context.read())
              as VehicleRepository,
    ),
    Provider(
      create: (context) =>
          JobsRepositoryRemote(apiClient: context.read()) as JobsRepository,
    ),
  ];
}

List<SingleChildWidget> get providersRemote {
  return [
    Provider(create: (context) => AuthApiClient()),
    Provider(create: (context) => ApiClient()),
    Provider(create: (context) => SharedPreferencesService()),
    ChangeNotifierProvider(
      create: (context) => throw UnimplementedError('Use providersLocal or implement AuthRepositoryRemote for sync'),
    ),
    Provider(
      create: (context) =>
          VehicleRepositoryRemote(apiClient: context.read())
              as VehicleRepository,
    ),
    Provider(
      create: (context) =>
          JobsRepositoryRemote(apiClient: context.read()) as JobsRepository,
    ),
  ];
}

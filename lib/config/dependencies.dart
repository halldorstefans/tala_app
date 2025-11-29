import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/jobs/jobs_repository_remote.dart';
import '../data/repositories/jobs/jobs_repository.dart';
import '../data/repositories/vehicle/vehicle_repository_remote.dart';
import '../data/repositories/vehicle/vehicle_repository.dart';
import '../data/services/shared_preferences_service.dart';
import '../data/services/tala_api/api_client.dart';
import '../data/services/tala_api/auth_api_client.dart';
import '../data/repositories/auth/auth_repository_remote.dart';
import '../data/repositories/auth/auth_repository.dart';

List<SingleChildWidget> get providersRemote {
  return [
    Provider(create: (context) => AuthApiClient()),
    Provider(create: (context) => ApiClient()),
    Provider(create: (context) => SharedPreferencesService()),
    ChangeNotifierProvider(
      create: (context) =>
          AuthRepositoryRemote(
                authApiClient: context.read(),
                apiClient: context.read(),
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

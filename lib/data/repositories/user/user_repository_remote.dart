import '../../../domain/models/user.dart';
import '../../../utils/result.dart';
import '../../services/tala_api/api_client.dart';
import 'user_repository.dart';

class UserRepositoryRemote implements UserRepository {
  UserRepositoryRemote({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  User? _cachedData;

  @override
  Future<Result<User>> getUser({required String userId}) async {
    if (_cachedData != null) {
      return Future.value(Result.ok(_cachedData!));
    }

    // TODO: Implement with local storage or remove when drift is added
    return Result.error(Exception('UserRepository not implemented for local-first'));
  }
}

import '../../../domain/models/user.dart';
import '../../../utils/result.dart';
import '../../services/tala_api/api_client.dart';
import '../../models/user_api_model.dart';
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

    final result = await _apiClient.getUser(userId);
    switch (result) {
      case Ok<UserApiModel>():
        final user = User(
          firstName: result.value.firstName,
          lastName: result.value.lastName,
        );
        _cachedData = user;
        return Result.ok(user);
      case Error<UserApiModel>():
        return Result.error(result.error);
    }
  }
}

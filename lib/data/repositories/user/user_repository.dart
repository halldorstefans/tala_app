import '../../../domain/models/user.dart';
import '../../../utils/result.dart';

abstract class UserRepository {
  Future<Result<User>> getUser({required String userId});
}

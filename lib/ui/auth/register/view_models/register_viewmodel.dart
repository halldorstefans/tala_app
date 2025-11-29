import 'package:logging/logging.dart';

import '../../../../data/repositories/auth/auth_repository.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';

class RegisterViewModel {
  RegisterViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    register =
        Command1<
          void,
          (String email, String password, String firstName, String lastName)
        >(_register);
    userId = "";
  }

  final AuthRepository _authRepository;
  final _log = Logger('RegisterViewModel');

  late String userId;
  late Command1 register;

  Future<Result<String>> _register(
    (String, String, String, String) details,
  ) async {
    final (email, password, firstName, lastName) = details;
    final result = await _authRepository.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    if (result is Error<String>) {
      _log.warning('Registration failed! ${result.error}');
    }
    userId = result is Ok<String> ? result.value : "";
    return result;
  }
}

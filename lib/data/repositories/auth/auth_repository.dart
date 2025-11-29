import 'package:flutter/foundation.dart';
import '../../../utils/result.dart';

abstract class AuthRepository extends ChangeNotifier {
  Future<bool> get isAuthenticated;

  Future<Result<String>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<Result<void>> login({required String email, required String password});

  Future<Result<void>> logout();
}

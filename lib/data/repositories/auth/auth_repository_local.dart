import 'dart:convert';

import '../../../utils/result.dart';
import '../../services/shared_preferences_service.dart';
import 'auth_repository.dart';

class AuthRepositoryLocal extends AuthRepository {
  AuthRepositoryLocal({required SharedPreferencesService sharedPreferencesService})
      : _sharedPreferencesService = sharedPreferencesService;

  final SharedPreferencesService _sharedPreferencesService;

  static const _userKey = 'LOCAL_USER';
  bool? _isAuthenticated;

  @override
  Future<bool> get isAuthenticated async {
    if (_isAuthenticated != null) {
      return _isAuthenticated!;
    }
    final userJson = await _sharedPreferencesService.getString(_userKey);
    _isAuthenticated = userJson != null;
    return _isAuthenticated!;
  }

  Future<void> _ensureUser() async {
    final existing = await _sharedPreferencesService.getString(_userKey);
    if (existing != null) {
      return;
    }

    final user = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'firstName': 'Owner',
      'lastName': '',
    };
    await _sharedPreferencesService.setString(_userKey, jsonEncode(user));
    _isAuthenticated = true;
  }

  @override
  Future<Result<String>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    await _ensureUser();
    notifyListeners();
    return Result.ok('local-user');
  }

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    await _ensureUser();
    notifyListeners();
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> logout() async {
    _isAuthenticated = false;
    await _sharedPreferencesService.remove(_userKey);
    notifyListeners();
    return const Result.ok(null);
  }
}
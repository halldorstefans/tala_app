import 'package:logging/logging.dart';
import 'package:tala_app/data/services/tala_api/api_client.dart';
import 'package:tala_app/utils/result.dart';

import '../../services/tala_api/auth_api_client.dart';
import '../../models/login_request.dart';
import '../../models/login_response.dart';
import '../../models/register_request.dart';
import '../../services/shared_preferences_service.dart';
import 'auth_repository.dart';

import 'package:jwt_decoder/jwt_decoder.dart';

class AuthRepositoryRemote extends AuthRepository {
  AuthRepositoryRemote({
    required ApiClient apiClient,
    required AuthApiClient authApiClient,
    required SharedPreferencesService sharedPreferencesService,
  }) : _apiClient = apiClient,
       _authApiClient = authApiClient,
       _sharedPreferencesService = sharedPreferencesService {
    _apiClient.authHeaderProvider = _authHeaderProvider;
  }

  final ApiClient _apiClient;
  final AuthApiClient _authApiClient;
  final SharedPreferencesService _sharedPreferencesService;

  bool? _isAuthenticated;
  String? _authToken;
  final _log = Logger('AuthRepositoryRemote');

  Future<void> _fetch() async {
    final result = await _sharedPreferencesService.fetchToken();
    switch (result) {
      case Ok<String?>():
        _authToken = result.value;
        if (result.value != null && !_isTokenExpired(result.value!)) {
          _isAuthenticated = true;
        } else {
          _isAuthenticated = false;
          _authToken = null;
          await _sharedPreferencesService.saveToken(null);
        }
      case Error<String?>():
        _log.severe(
          'Failed to fetch Token from SharedPreferences',
          result.error,
        );
    }
  }

  bool _isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      _log.warning('Failed to decode token: $e');
      return true;
    }
  }

  @override
  Future<bool> get isAuthenticated async {
    // Status is cached, but check token expiry if cached is true
    if (_isAuthenticated != null) {
      if (_isAuthenticated! &&
          _authToken != null &&
          _isTokenExpired(_authToken!)) {
        _log.info('Token expired (cached), logging out');
        await logout();
        return false;
      }
      _log.info('isAuthenticated (cached): $_isAuthenticated');
      return _isAuthenticated!;
    }

    await _fetch();
    _log.info('isAuthenticated (fetched): $_isAuthenticated');
    return _isAuthenticated ?? false;
  }

  @override
  Future<Result<String>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final result = await _authApiClient.register(
        RegisterRequest(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        ),
      );
      switch (result) {
        case Ok<LoginResponse>():
          _log.info('User registered');
          _isAuthenticated = true;
          _authToken = result.value.token;
          await _sharedPreferencesService.saveToken(result.value.token);

          return Result.ok(result.value.userId);
        case Error<LoginResponse>():
          _log.warning('Error registering: ${result.error}');
          return Result.error(result.error);
      }
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authApiClient.login(
        LoginRequest(email: email, password: password),
      );
      switch (result) {
        case Ok<LoginResponse>():
          _log.info('User logged in');
          if (!_isTokenExpired(result.value.token)) {
            _isAuthenticated = true;
            _authToken = result.value.token;
            return await _sharedPreferencesService.saveToken(
              result.value.token,
            );
          } else {
            _isAuthenticated = false;
            _authToken = null;
            await _sharedPreferencesService.saveToken(null);
            return Result.error(Exception('Received expired token'));
          }
        case Error<LoginResponse>():
          _log.warning('Error logging in: ${result.error}');
          return Result.error(result.error);
      }
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> logout() async {
    _log.info('User logged out');
    try {
      final result = await _sharedPreferencesService.saveToken(null);
      if (result is Error<void>) {
        _log.severe('Failed to clear stored auth token');
      }

      _authToken = null;

      _isAuthenticated = false;
      return result;
    } finally {
      notifyListeners();
    }
  }

  String? _authHeaderProvider() =>
      _authToken != null ? 'Bearer $_authToken' : null;
}

import 'package:jwt_decoder/jwt_decoder.dart';

class LoginResponse {
  final String token;
  final String userId;

  LoginResponse({required this.token, required this.userId});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String;
    final userId = json['user_id'] as String? ?? _userIdFromToken(token);
    return LoginResponse(token: token, userId: userId);
  }

  static String _userIdFromToken(String token) {
    try {
      final claims = JwtDecoder.decode(token);
      return claims['sub'] as String? ?? claims['id'] as String? ?? '';
    } catch (_) {
      return '';
    }
  }
}

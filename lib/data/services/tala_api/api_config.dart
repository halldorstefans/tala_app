class ApiConfig {
  static const String baseUrl = String.fromEnvironment('API_URL');

  static String getPhotoUrl(String path) => baseUrl + path;

  static bool isValidPhotoPath(String? path) =>
      path != null && path.isNotEmpty && path != 'null' && path.startsWith('/uploads/');
}

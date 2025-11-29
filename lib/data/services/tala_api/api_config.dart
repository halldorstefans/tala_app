class ApiConfig {
  static const String baseUrl = String.fromEnvironment('API_URL');

  // Helper to build full image URLs
  static String getPhotoUrl(String path) {
    return baseUrl + path;
  }
}

import 'package:path_provider/path_provider.dart';

class ApiConfig {
  static const String baseUrl = String.fromEnvironment('API_URL');

  static String getPhotoUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('photos/') || path.startsWith('photos\\')) {
      return path;
    }
    return baseUrl + path;
  }

  static bool isValidPhotoPath(String? path) =>
      path != null &&
      path.isNotEmpty &&
      path != 'null' &&
      (path.startsWith('/uploads/') || path.startsWith('photos/') || path.startsWith('photos\\'));

  static Future<String> getLocalPhotoPath(String relativePath) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$relativePath';
  }
}

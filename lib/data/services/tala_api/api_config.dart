import 'package:path_provider/path_provider.dart';

/// Photo-path helpers. In local-first mode every photo lives on disk as a
/// relative `photos/<uuid>.<ext>` path; these resolve and validate it. (The
/// former remote-URL helpers went with the removed API layer.)
class ApiConfig {
  static bool isValidPhotoPath(String? path) =>
      path != null &&
      path.isNotEmpty &&
      path != 'null' &&
      (path.startsWith('/uploads/') ||
          path.startsWith('photos/') ||
          path.startsWith('photos\\'));

  static Future<String> getLocalPhotoPath(String relativePath) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$relativePath';
  }
}

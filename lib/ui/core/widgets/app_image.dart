import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tala_app/data/services/tala_api/api_config.dart';

class AppImage extends StatelessWidget {
  final String? path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData placeholderIcon;
  final double placeholderSize;

  const AppImage({
    super.key,
    this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.image,
    this.placeholderSize = 40,
  });

  static Future<ImageProvider> resolveProvider(String path) async {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    final fullPath = await ApiConfig.getLocalPhotoPath(path);
    return FileImage(File(fullPath));
  }

  bool get _isNetwork =>
      path != null &&
      (path!.startsWith('http://') || path!.startsWith('https://'));

  bool get _hasValidPath =>
      path != null && path!.isNotEmpty && path != 'null';

  Widget get _placeholder => Icon(placeholderIcon, size: placeholderSize);

  @override
  Widget build(BuildContext context) {
    if (!_hasValidPath) return _placeholder;

    if (_isNetwork) {
      return Image.network(
        path!,
        width: width,
        height: height,
        fit: fit,
      );
    }

    return FutureBuilder<String>(
      future: ApiConfig.getLocalPhotoPath(path!),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final file = File(snapshot.data!);
          if (file.existsSync()) {
            return Image.file(
              file,
              width: width,
              height: height,
              fit: fit,
            );
          }
        }
        return _placeholder;
      },
    );
  }
}

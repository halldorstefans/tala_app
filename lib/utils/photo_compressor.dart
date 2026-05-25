import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

typedef PhotoCompressor = Future<File?> Function(File source);

Future<File?> defaultPhotoCompressor(File source) async {
  final compressed = await FlutterImageCompress.compressAndGetFile(
    source.absolute.path,
    '${source.parent.path}/compressed_${source.uri.pathSegments.last}',
    quality: 85,
  );
  return compressed != null ? File(compressed.path) : null;
}

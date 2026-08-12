import 'package:path/path.dart' as p;

/// Raster image extensions we treat as viewable images: shown as a thumbnail,
/// opened in the full-screen gallery, and safe to run through the (JPEG-only)
/// photo compressor. Anything else is a document — a file glyph + OS hand-off,
/// never compressed.
const imageExtensions = {
  '.jpg',
  '.jpeg',
  '.png',
  '.gif',
  '.webp',
  '.heic',
  '.bmp',
};

/// Whether [path]'s extension marks it as a viewable image. [type] on an
/// attachment is a separate user label (a receipt can be a JPG or a PDF), so
/// image-ness is judged from the file itself.
bool isImagePath(String path) =>
    imageExtensions.contains(p.extension(path).toLowerCase());

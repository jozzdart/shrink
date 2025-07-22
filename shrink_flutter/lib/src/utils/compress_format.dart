import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Generates a file name for the compressed image.
///
/// - [format]: The format of the image.
///
/// Returns a string with the file name.
String compressFormatToFileName(CompressFormat format) {
  return 'compressed_${DateTime.now().millisecondsSinceEpoch}.${_compressFormatToString(format)}';
}

/// Maps [CompressFormat] to appropriate file extension.
String _compressFormatToString(CompressFormat format) {
  switch (format) {
    case CompressFormat.jpeg:
      return 'jpg';
    case CompressFormat.png:
      return 'png';
    case CompressFormat.heic:
      return 'heic';
    case CompressFormat.webp:
      return 'webp';
    default:
      return 'img';
  }
}

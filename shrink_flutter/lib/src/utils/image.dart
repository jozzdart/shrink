import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Compresses an image file using [flutter_image_compress].
///
/// Returns a new [File] containing the compressed image, or `null` if compression fails.
///
/// Parameters:
/// - [file]: The original image to compress.
/// - [quality]: JPEG/WebP/HEIC quality (0–100). Defaults to `70`.
/// - [minWidth], [minHeight]: Optional resizing dimensions. Defaults to `720x720`.
/// - [format]: Output image format. Defaults to [CompressFormat.jpeg].
Future<File?> shrinkImage(
  File file, {
  int quality = 70,
  int minWidth = 720,
  int minHeight = 720,
  CompressFormat format = CompressFormat.jpeg,
}) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'compressed_${DateTime.now().millisecondsSinceEpoch}.${_formatExtension(format)}';
    final targetPath = path.join(
      tempDir.path,
      fileName,
    );

    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      format: format,
    );

    return compressed == null ? null : File(compressed.path);
  } catch (e) {
    return null;
  }
}

/// Maps [CompressFormat] to appropriate file extension.
String _formatExtension(CompressFormat format) {
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

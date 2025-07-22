import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'compress_format.dart';

/// Compresses an image file using [flutter_image_compress].
///
/// Returns a new [File] containing the compressed image, or `null` if compression fails.
///
/// Parameters:
/// - [file]: The original image to compress.
/// - [quality]: JPEG/WebP/HEIC quality (0–100). Defaults to `70`.
/// - [minWidth], [minHeight]: Optional resizing dimensions. Defaults to `720x720`.
/// - [format]: Output image format. Defaults to [CompressFormat.jpeg].
/// - [inSampleSize]: The sample size for the image. Defaults to `1`.
/// - [rotate]: The rotation of the image. Defaults to `0`.
/// - [autoCorrectionAngle]: Whether to automatically correct the angle of the image. Defaults to `true`.
/// - [keepExif]: Whether to keep the EXIF data of the image. Defaults to `false`.
/// - [numberOfRetries]: The number of times to retry the compression. Defaults to `5`.
///
/// Returns a new [File] containing the compressed image, or `null` if compression fails.
Future<File?> shrinkImage(
  File file, {
  int quality = 70,
  int minWidth = 720,
  int minHeight = 720,
  CompressFormat format = CompressFormat.jpeg,
  int inSampleSize = 1,
  int rotate = 0,
  bool autoCorrectionAngle = true,
  bool keepExif = false,
  int numberOfRetries = 5,
}) async {
  try {
    final targetPath = await _generateTargetPath(format);
    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      format: format,
      inSampleSize: inSampleSize,
      rotate: rotate,
      autoCorrectionAngle: autoCorrectionAngle,
      keepExif: keepExif,
      numberOfRetries: numberOfRetries,
    );

    return compressed == null ? null : File(compressed.path);
  } catch (e) {
    return null;
  }
}

Future<String> _generateTargetPath(CompressFormat format) async {
  final tempDir = await getTemporaryDirectory();
  final fileName = compressFormatToFileName(format);
  return path.join(tempDir.path, fileName);
}

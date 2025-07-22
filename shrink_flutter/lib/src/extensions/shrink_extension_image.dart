import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../utils/image.dart';

extension ShrinkImageExtension on File {
  /// Compresses an image file using [flutter_image_compress].
  ///
  /// Returns a new [File] containing the compressed image, or `null` if compression fails.
  ///
  /// Parameters:
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
  Future<File?> shrink({
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
    return shrinkImage(
      this,
      format: format,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      inSampleSize: inSampleSize,
      rotate: rotate,
      autoCorrectionAngle: autoCorrectionAngle,
      keepExif: keepExif,
      numberOfRetries: numberOfRetries,
    );
  }
}

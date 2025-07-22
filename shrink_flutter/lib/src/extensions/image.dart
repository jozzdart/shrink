import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../utils/image.dart';

extension ShrinkImageExtension on File {
  /// Extension method on [File] to compress an image using [shrinkImage].
  ///
  /// This is equivalent to calling `shrinkImage(file)` but allows chaining.
  ///
  /// - [quality]: JPEG/WebP/HEIC quality between 0–100. Defaults to 70.
  /// - [minWidth], [minHeight]: Resize dimensions. Defaults to 720px.
  /// - [format]: Output image format. Defaults to [CompressFormat.jpeg].
  ///
  /// Returns a new compressed [File], or `null` if compression fails.
  Future<File?> shrink({
    CompressFormat format = CompressFormat.jpeg,
    int quality = 70,
    int minWidth = 720,
    int minHeight = 720,
  }) async {
    return shrinkImage(
      this,
      format: format,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
    );
  }
}

import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../utils/compress_format.dart';

/// Extension on [CompressFormat] to provide utility methods.
extension CompressFormatExtension on CompressFormat {
  /// Generates a file name for the compressed image using the current [CompressFormat].
  ///
  /// Example:
  /// ```
  /// final fileName = CompressFormat.jpeg.generateFileName();
  /// // fileName might be 'compressed_1681234567890.jpg'
  /// ```
  String generateFileName() => compressFormatToFileName(this);
}

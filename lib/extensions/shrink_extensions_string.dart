import 'dart:convert';
import 'dart:typed_data';

import 'package:shrink/utils/utils.dart' as utils;

/// Extensions on [String] for compression operations.
///
/// These extension methods make it more convenient to compress string data
/// and decode base64-encoded strings.
extension ShrinkExtensionsString on String {
  /// Compresses this string using UTF-8 encoding and zlib compression.
  ///
  /// This method encodes the string as UTF-8, then applies zlib compression
  /// to reduce its size. For decompression, use [Uint8List.restoreText].
  ///
  /// Returns a [Uint8List] containing the compressed string data.
  Uint8List shrink() => utils.shrinkText(this);

  /// Decodes this base64-encoded string to a [Uint8List].
  ///
  /// This method is the inverse of [Uint8List.toBase64].
  ///
  /// Returns the original binary data as a [Uint8List].
  /// Throws a [FormatException] if the string is not valid base64.
  Uint8List fromBase64() => base64Decode(this);
}

import 'dart:typed_data';

import '../utils/utils.dart' as utils;

/// Extensions on [Map<String, dynamic>] for JSON compression operations.
///
/// These extension methods make it more convenient to compress JSON data
/// by allowing method chaining on Map objects.
extension ShrinkExtensionsJson on Map<String, dynamic> {
  /// Compresses this JSON object to a compact binary representation.
  ///
  /// This method first encodes the JSON object to a minified string,
  /// then compresses that string using UTF-8 encoding and zlib compression.
  /// For decompression, use [Uint8List.restoreJson] or [Restore.json].
  ///
  /// Returns a [Uint8List] containing the compressed JSON data.
  Uint8List shrink() => utils.shrinkJson(this);
}

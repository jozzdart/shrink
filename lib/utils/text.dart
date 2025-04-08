import 'dart:convert';
import 'dart:typed_data';

import 'package:shrink/utils/bytes.dart';

/// Compresses a string using UTF-8 encoding and zlib compression.
///
/// This function first converts the string to UTF-8 encoded bytes, then
/// applies zlib compression to reduce the size.
///
/// Returns a [Uint8List] containing the compressed string data.
Uint8List shrinkText(String text) {
  final bytes = utf8.encode(text);
  return shrinkBytes(bytes);
}

/// Decompresses a [Uint8List] that was compressed using [shrinkText].
///
/// This function first decompresses the zlib-compressed data using [restoreBytes],
/// then decodes the resulting bytes as a UTF-8 string.
///
/// Returns the original string.
/// Throws a [FormatException] if the decompressed data is not valid UTF-8.
String restoreText(Uint8List shrunken) {
  final restored = restoreBytes(shrunken);
  return utf8.decode(restored);
}

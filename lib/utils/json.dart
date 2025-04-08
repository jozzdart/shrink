import 'dart:convert';
import 'dart:typed_data';

import 'text.dart';

/// Compresses a JSON object to a compact binary representation.
///
/// This function first encodes the JSON object to a string using [jsonEncode],
/// which minifies the JSON by removing unnecessary whitespace. The minified JSON
/// string is then compressed using [shrinkText], which applies UTF-8 encoding
/// followed by zlib compression.
///
/// Returns a [Uint8List] containing the compressed JSON data.
Uint8List shrinkJson(Map<String, dynamic> data) {
  final minified = jsonEncode(data); // Minified JSON string
  return shrinkText(minified); // Compress the string
}

/// Decompresses and parses JSON data that was compressed using [shrinkJson].
///
/// This function first decompresses the data using [restoreText] to recover
/// the JSON string, then parses it back into a Dart object using [jsonDecode].
///
/// Returns the original [Map<String, dynamic>] that was compressed.
/// Throws [FormatException] if the decompressed data is not valid JSON.
Map<String, dynamic> restoreJson(Uint8List compressed) {
  final minified = restoreText(compressed);
  return jsonDecode(minified);
}

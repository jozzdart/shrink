import 'dart:convert';
import 'dart:typed_data';

import 'text.dart';

/// Compress JSON to a base64 string using zlib after minifying.
Uint8List shrinkJson(Map<String, dynamic> data) {
  final minified = jsonEncode(data); // Minified JSON string
  return shrinkText(minified); // Make it a string
}

/// Decompress base64 string back to Map.
Map<String, dynamic> restoreJson(Uint8List shrunked) {
  final compressed = restoreText(shrunked);
  return jsonDecode(compressed);
}

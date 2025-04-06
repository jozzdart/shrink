import 'dart:typed_data';

import 'package:shrink/utils/utils.dart';

/// A utility class for compressing different types of data.
///
/// This class provides static methods to compress various data types:
/// - bytes: Compresses raw binary data using zlib
/// - json: Compresses JSON objects efficiently
/// - text: Compresses strings using UTF-8 encoding and zlib
/// - unique: Compresses lists of unique integers using specialized algorithms
///
/// Example:
/// ```dart
/// // Compress a string
/// final compressed = Shrink.text('Hello world!');
///
/// // Compress a JSON object
/// final jsonCompressed = Shrink.json({'name': 'John', 'age': 30});
/// ```
abstract class Shrink {
  /// Compresses a [Uint8List] of bytes using zlib compression.
  ///
  /// Returns a compressed [Uint8List].
  static Uint8List bytes(Uint8List bytes) {
    return shrinkBytes(bytes);
  }

  /// Compresses a JSON object (Map<String, dynamic>) using efficient encoding.
  ///
  /// Returns a compressed [Uint8List].
  static Uint8List json(Map<String, dynamic> json) {
    return shrinkJson(json);
  }

  /// Compresses a string using UTF-8 encoding and zlib compression.
  ///
  /// Returns a compressed [Uint8List].
  static Uint8List text(String text) {
    return shrinkText(text);
  }

  /// Compresses a list of unique integers using the most efficient algorithm.
  ///
  /// The algorithm automatically selects the best compression method from:
  /// delta-encoding with variable-length integers, run-length encoding,
  /// chunked encoding, or bitmask encoding.
  ///
  /// Returns a compressed [Uint8List].
  static Uint8List unique(List<int> uniqueList) {
    return shrinkUnique(uniqueList);
  }
}

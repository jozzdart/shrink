import 'dart:typed_data';

import 'package:shrink/utils/utils.dart';

/// A utility class for compressing different types of data.
///
/// This class provides static methods to compress various data types:
/// - bytes: Compresses raw binary data using multiple compression algorithms and selects the best result (identity, ZLIB, or GZIP)
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
  /// Compresses a [Uint8List] using multiple compression algorithms and selects the best result.
  ///
  /// This function tries different compression methods and levels to find the optimal compression:
  /// - No compression (identity) - used when compression would increase size
  /// - ZLIB compression with levels 1-9
  /// - GZIP compression with levels 1-9
  ///
  /// The first byte of the returned [Uint8List] indicates the compression method used,
  /// followed by the compressed data.
  ///
  /// Returns a compressed [Uint8List] using the most efficient method for the input data.
  /// The compression is lossless - the original data can be fully restored.
  static Uint8List bytes(Uint8List bytes) {
    return shrinkBytes(bytes);
  }

  /// Compresses a JSON object using efficient encoding.
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

  /// Compresses a list of unique integers using a specified compression method.
  ///
  /// Important: The automatic [unique] method is recommended over this manual option
  /// in most cases, as it intelligently selects the optimal compression algorithm,
  /// which can yield significantly better compression ratios for different data patterns.
  ///
  /// Parameters:
  ///   [uniqueList]: The list of unique integers to compress
  ///   [method]: The specific compression method to use
  ///
  /// Returns a compressed [Uint8List].
  static Uint8List uniqueManual(
      List<int> uniqueList, UniqueCompressionMethod method) {
    return shrinkUniqueManual(uniqueList, method);
  }
}

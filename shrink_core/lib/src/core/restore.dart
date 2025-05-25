import 'dart:typed_data';

import '../utils/utils.dart';

/// A utility class for decompressing data that was compressed using the [Shrink] class.
///
/// This class provides static methods to decompress various data types:
/// - bytes: Decompresses raw binary data using the optimal compression method (identity or ZLIB)
/// - json: Decompresses and parses JSON objects
/// - text: Decompresses strings encoded with UTF-8 and compressed with zlib
/// - unique: Decompresses lists of unique integers
///
/// Example:
/// ```dart
/// // Decompress bytes back to a string
/// final decompressed = Restore.text(compressedBytes);
///
/// // Decompress bytes back to a JSON object
/// final jsonData = Restore.json(jsonCompressedBytes);
/// ```
abstract class Restore {
  /// Decompresses a [Uint8List] that was compressed using [Shrink.bytes].
  ///
  /// This function reads the compression method from the first byte and applies
  /// the appropriate decompression algorithm:
  /// - Identity (no compression)
  /// - ZLIB decompression for ZLIB-compressed data
  ///
  /// Note: For backward compatibility, it also supports legacy compression methods
  /// from versions prior to 1.5.6.
  ///
  /// Returns the original uncompressed [Uint8List].
  /// Throws [ArgumentError] if the input is empty.
  /// Throws [UnsupportedError] if the compression method is unknown.
  /// May throw [FormatException] if the compressed data is corrupted.
  static Uint8List bytes(Uint8List compressed) {
    return restoreBytes(compressed);
  }

  /// Decompresses a [Uint8List] that was compressed using [Shrink.json]
  /// and converts it back to a JSON object.
  ///
  /// Returns the original [Map<String, dynamic>] JSON object.
  static Map<String, dynamic> json(Uint8List compressed) {
    return restoreJson(compressed);
  }

  /// Decompresses a [Uint8List] that was compressed using [Shrink.text]
  /// and converts it back to a string.
  ///
  /// Returns the original UTF-8 encoded string.
  static String text(Uint8List compressed) {
    return restoreText(compressed);
  }

  /// Decompresses a [Uint8List] that was compressed using [Shrink.unique]
  /// and converts it back to a list of unique integers.
  ///
  /// Returns the original list of unique integers.
  static List<int> unique(Uint8List compressed) {
    return restoreUnique(compressed);
  }
}

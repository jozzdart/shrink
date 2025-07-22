import 'package:flutter/foundation.dart';
import 'package:shrink/shrink.dart';

/// An asynchronous utility class for decompressing data that was compressed using the [Shrink] class.
///
/// Uses [compute] to offload decompression to an isolate for UI performance.
/// Always returns the same output as `Restore.*` but wrapped in a `Future`.
///
/// Example:
/// ```dart
/// final decompressedText = await RestoreAsync.text(compressedTextBytes);
/// final decompressedJson = await RestoreAsync.json(compressedJsonBytes);
/// ```
///
/// This class provides static methods corresponding to the compression methods
/// in `ShrinkAsync`, allowing restoration of data in separate isolates to avoid
/// blocking the UI.
///
/// Always restores data compressed by the corresponding `ShrinkAsync.*` methods.
abstract class RestoreAsync {
  /// Asynchronously decompresses a [Uint8List] that was compressed using [Shrink.bytes].
  ///
  /// This function reads the compression method from the first byte and applies
  /// the appropriate decompression algorithm in a separate isolate:
  /// - Identity (no compression)
  /// - ZLIB decompression for ZLIB-compressed data
  ///
  /// Note: For backward compatibility, it also supports legacy compression methods
  /// from versions prior to 1.5.6.
  ///
  /// Returns a [Future] containing the original uncompressed [Uint8List].
  /// The future may complete with an [ArgumentError] if the input is empty.
  /// The future may complete with an [UnsupportedError] if the compression method is unknown.
  /// The future may complete with a [FormatException] if the compressed data is corrupted.
  static Future<Uint8List> bytes(Uint8List compressed) {
    return compute(_restoreBytesIsolate, compressed);
  }

  /// Asynchronously decompresses a [Uint8List] that was compressed using [Shrink.json]
  /// and converts it back to a JSON object in a separate isolate.
  ///
  /// Returns a [Future] containing the original [Map<String, dynamic>] JSON object.
  static Future<Map<String, dynamic>> json(Uint8List compressed) {
    return compute(_restoreJsonIsolate, compressed);
  }

  /// Asynchronously decompresses a [Uint8List] that was compressed using [Shrink.text]
  /// and converts it back to a string in a separate isolate.
  ///
  /// Returns a [Future] containing the original UTF-8 encoded string.
  static Future<String> text(Uint8List compressed) {
    return compute(_restoreTextIsolate, compressed);
  }

  /// Asynchronously decompresses a [Uint8List] that was compressed using [Shrink.unique]
  /// and converts it back to a list of unique integers in a separate isolate.
  ///
  /// Returns a [Future] containing the original list of unique integers.
  static Future<List<int>> unique(Uint8List compressed) {
    return compute(_restoreUniqueIsolate, compressed);
  }
}

// --- Isolate wrappers ---

Uint8List _restoreBytesIsolate(Uint8List compressed) =>
    restoreBytes(compressed);

Map<String, dynamic> _restoreJsonIsolate(Uint8List compressed) =>
    restoreJson(compressed);

String _restoreTextIsolate(Uint8List compressed) => restoreText(compressed);

List<int> _restoreUniqueIsolate(Uint8List compressed) =>
    restoreUnique(compressed);

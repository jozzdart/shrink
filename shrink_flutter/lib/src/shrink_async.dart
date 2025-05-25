import 'package:flutter/foundation.dart';
import 'package:shrink/shrink.dart';

/// An asynchronous utility class for compressing different types of data without blocking the UI.
///
/// This class provides static methods to compress various data types using separate isolates via [compute]:
/// - bytes: Compresses raw binary data using identity or ZLIB compression and selects the best result
/// - json: Compresses JSON objects efficiently
/// - text: Compresses strings using UTF-8 encoding and zlib
/// - unique: Compresses lists of unique integers using specialized algorithms
///
/// Always returns the same output as `Shrink.*` but wrapped in a `Future`.
///
/// Example:
/// ```dart
/// // Asynchronously compress a string
/// final compressedFuture = ShrinkAsync.text('Hello world!');
/// final compressedBytes = await compressedFuture;
///
/// // Asynchronously compress a JSON object
/// final jsonCompressedFuture = ShrinkAsync.json({'name': 'John', 'age': 30});
/// final jsonCompressedBytes = await jsonCompressedFuture;
/// ```
abstract class ShrinkAsync {
  /// Asynchronously compresses a [Uint8List] using zlib compression or no compression (identity).
  ///
  /// This function tries different compression levels to find the optimal compression:
  /// - No compression (identity) - used when compression would increase size
  /// - ZLIB compression with levels 4-9
  ///
  /// The first byte of the resulting [Uint8List] indicates the compression method used,
  /// followed by the compressed data.
  ///
  /// This method runs the compression in a separate isolate using [compute] to avoid
  /// blocking the main thread.
  ///
  /// Returns a `Future<Uint8List>` containing the compressed data using the most
  /// efficient method for the input data. The compression is lossless - the
  /// original data can be fully restored.
  static Future<Uint8List> bytes(Uint8List bytes) {
    return compute(_shrinkBytesIsolate, bytes);
  }

  /// Asynchronously compresses a JSON object using efficient encoding.
  ///
  /// This method runs the compression in a separate isolate using [compute].
  ///
  /// Returns a `Future<Uint8List>` containing the compressed data.
  static Future<Uint8List> json(Map<String, dynamic> json) {
    return compute(_shrinkJsonIsolate, json);
  }

  /// Asynchronously compresses a string using UTF-8 encoding and zlib compression.
  ///
  /// This method runs the compression in a separate isolate using [compute].
  ///
  /// Returns a `Future<Uint8List>` containing the compressed data.
  static Future<Uint8List> text(String text) {
    return compute(_shrinkTextIsolate, text);
  }

  /// Asynchronously compresses a list of unique integers using the most efficient algorithm.
  ///
  /// The algorithm automatically selects the best compression method from:
  /// delta-encoding with variable-length integers, run-length encoding,
  /// chunked encoding, or bitmask encoding.
  ///
  /// This method runs the compression in a separate isolate using [compute].
  ///
  /// Returns a `Future<Uint8List>` containing the compressed data.
  static Future<Uint8List> unique(List<int> list) {
    return compute(_shrinkUniqueIsolate, list);
  }

  /// Asynchronously compresses a list of unique integers using a specified compression method.
  ///
  /// Important: The automatic [unique] method is recommended over this manual option
  /// in most cases, as it intelligently selects the optimal compression algorithm,
  /// which can yield significantly better compression ratios for different data patterns.
  ///
  /// This method runs the compression in a separate isolate using [compute].
  ///
  /// Parameters:
  ///   [args]: An instance of [UniqueManualArgs] containing the list and the method.
  ///
  /// Returns a `Future<Uint8List>` containing the compressed data.
  static Future<Uint8List> uniqueManual(UniqueManualArgs args) {
    return compute(_shrinkUniqueManualIsolate, args);
  }
}

// --- Isolate wrappers ---

Uint8List _shrinkBytesIsolate(Uint8List bytes) => shrinkBytes(bytes);

Uint8List _shrinkJsonIsolate(Map<String, dynamic> json) => shrinkJson(json);

Uint8List _shrinkTextIsolate(String text) => shrinkText(text);

Uint8List _shrinkUniqueIsolate(List<int> list) => shrinkUnique(list);

Uint8List _shrinkUniqueManualIsolate(UniqueManualArgs args) =>
    shrinkUniqueManual(args.list, args.method);

/// Helper class for isolate args
class UniqueManualArgs {
  final List<int> list;
  final UniqueCompressionMethod method;

  const UniqueManualArgs(this.list, this.method);
}

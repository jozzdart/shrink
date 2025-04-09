import 'dart:convert';
import 'dart:typed_data';

import 'package:shrink/utils/utils.dart' as utils;

/// Extensions on [Uint8List] for compression and decompression operations.
///
/// These extension methods make it more convenient to work with compressed data
/// by allowing method chaining and providing a more fluent API.
extension ShrinkExtensionsBytes on Uint8List {
  /// Compresses this [Uint8List] using multiple compression algorithms and selects the best result.
  ///
  /// This method tries different compression methods and levels to find the optimal compression:
  /// - No compression (identity) - used when compression would increase size
  /// - ZLIB compression with levels 1-9
  /// - GZIP compression with levels 1-9
  ///
  /// The first byte of the returned [Uint8List] indicates the compression method used,
  /// followed by the compressed data.
  ///
  /// Returns a compressed [Uint8List] using the most efficient method for the input data.
  /// The compression is lossless - the original data can be fully restored.
  Uint8List shrink() => utils.shrinkBytes(this);

  /// Converts this [Uint8List] to a base64-encoded string.
  ///
  /// Useful for converting binary data to a text representation that can be
  /// easily stored or transmitted as text.
  String toBase64() => base64Encode(this);

  /// Decompresses this [Uint8List] as text data.
  ///
  /// This method should be used on data that was compressed with
  /// [String.shrinkText] or [Shrink.text].
  ///
  /// Returns the original string.
  String restoreText() => utils.restoreText(this);

  /// Decompresses this [Uint8List] as binary data.
  ///
  /// This method should be used on data that was compressed with
  /// [Uint8List.shrinkBytes] or [Shrink.bytes].
  ///
  /// Returns the original uncompressed [Uint8List].
  Uint8List restoreBytes() => utils.restoreBytes(this);

  /// Decompresses this [Uint8List] as a JSON object.
  ///
  /// This method should be used on data that was compressed with
  /// [Map.shrinkJson] or [Shrink.json].
  ///
  /// Returns the original JSON object as a [Map<String, dynamic>].
  Map<String, dynamic> restoreJson() => utils.restoreJson(this);

  /// Decompresses this [Uint8List] as a list of unique integers.
  ///
  /// This method should be used on data that was compressed with
  /// [List<int>.shrinkUnique] or [Shrink.unique].
  ///
  /// Returns the original list of unique integers.
  List<int> restoreUnique() => utils.restoreUnique(this);
}

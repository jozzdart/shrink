import 'dart:typed_data';
import 'package:archive/archive.dart';

/// Compresses a [Uint8List] using multiple compression algorithms and selects the best result.
///
/// This function tries different compression methods and levels to find the optimal compression:
///
/// - No compression (identity) - used when compression would increase size
/// - ZLIB compression with levels 1-9
/// - GZIP compression with levels 1-9
///
/// The first byte of the returned [Uint8List] indicates the compression method used,
/// followed by the compressed data.
///
/// Returns a compressed [Uint8List] using the most efficient method for the input data.
/// The compression is lossless - the original data can be fully restored.
Uint8List shrinkBytes(Uint8List bytes) {
  final List<MapEntry<int, List<int>>> options = [];

  // Identity (no compression)
  options.add(MapEntry(_CompressionMethod.identity, bytes));

  final zLibEncoder = ZLibEncoder();
  final gZipEncoder = GZipEncoder();

  // Try zlib levels
  for (int level = 1; level <= 9; level++) {
    try {
      final encoded = zLibEncoder.encode(bytes, level: level);
      options.add(MapEntry(_CompressionMethod.zlib1 - 1 + level, encoded));
    } catch (_) {
      // skip failed compression
    }
  }

  // Try gzip levels
  for (int level = 1; level <= 9; level++) {
    try {
      final encoded = gZipEncoder.encode(bytes, level: level);
      options.add(MapEntry(_CompressionMethod.gzip1 - 10 + level, encoded));
    } catch (_) {
      // skip failed compression
    }
  }

  // Find the best result (smallest size)
  MapEntry<int, List<int>> best = options.first;
  for (var option in options) {
    if (option.value.length < best.value.length) {
      best = option;
    }
  }

  // Return best: method byte + compressed bytes
  final result = Uint8List(best.value.length + 1);
  result[0] = best.key;
  result.setRange(1, result.length, best.value);
  return result;
}

/// Decompresses a [Uint8List] that was compressed by [shrinkBytes].
///
/// This function reads the compression method from the first byte and applies
/// the appropriate decompression algorithm:
///
/// - Identity (no compression)
/// - ZLIB decompression for ZLIB-compressed data
/// - GZIP decompression for GZIP-compressed data
///
/// Returns the original, uncompressed [Uint8List].
/// Throws [ArgumentError] if the input is empty.
/// Throws [UnsupportedError] if the compression method is unknown.
/// May throw [FormatException] if the compressed data is corrupted.
Uint8List restoreBytes(Uint8List bytes) {
  if (bytes.isEmpty) throw ArgumentError('Input is empty');

  final method = bytes[0];
  final data = bytes.sublist(1);

  final zLibDecoder = ZLibDecoder();
  final gZipDecoder = GZipDecoder();

  if (method == _CompressionMethod.identity) {
    return data;
  } else if (method >= _CompressionMethod.zlib1 &&
      method <= _CompressionMethod.zlib9) {
    return Uint8List.fromList(zLibDecoder.decodeBytes(data));
  } else if (method >= _CompressionMethod.gzip1 &&
      method <= _CompressionMethod.gzip9) {
    return Uint8List.fromList(gZipDecoder.decodeBytes(data));
  }

  throw UnsupportedError('Unknown compression method: $method');
}

class _CompressionMethod {
  static const int identity = 0;
  static const int zlib1 = 1;
  static const int zlib9 = 9;

  static const int gzip1 = 10;
  static const int gzip9 = 18;
}

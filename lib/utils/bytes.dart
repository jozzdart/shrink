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
  // Start by assuming "no compression" is best (identity).
  int bestMethod = _CompressionMethod.identity;
  List<int> bestData = bytes;

  final zLibEncoder = ZLibEncoder();
  final gZipEncoder = GZipEncoder();

  // Try ZLIB levels
  for (int level = 1; level <= 9; level++) {
    try {
      final encoded = zLibEncoder.encode(bytes, level: level);
      if (encoded.length < bestData.length) {
        bestMethod = _CompressionMethod.zlib1 + (level - 1);
        bestData = encoded;
      }
    } catch (_) {
      // Skip if compression fails at this level
    }
  }

  // Try GZIP levels
  for (int level = 1; level <= 9; level++) {
    try {
      final encoded = gZipEncoder.encode(bytes, level: level);
      if (encoded.length < bestData.length) {
        bestMethod = _CompressionMethod.gzip1 + (level - 1);
        bestData = encoded;
      }
    } catch (_) {
      // Skip if compression fails at this level
    }
  }

  // Build the final [Uint8List]: method byte + compressed bytes
  final result = Uint8List(bestData.length + 1);
  result[0] = bestMethod;
  result.setRange(1, result.length, bestData);
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
  if (bytes.isEmpty) {
    throw ArgumentError('Input is empty');
  }

  final method = bytes[0];
  final data = bytes.sublist(1);

  if (method == _CompressionMethod.identity) {
    return data; // No compression
  }

  final zLibDecoder = ZLibDecoder();
  final gZipDecoder = GZipDecoder();

  if (_CompressionMethod.isZlib(method)) {
    return Uint8List.fromList(zLibDecoder.decodeBytes(data));
  } else if (_CompressionMethod.isGzip(method)) {
    return Uint8List.fromList(gZipDecoder.decodeBytes(data));
  } else if (_CompressionMethod.isLegacy(method)) {
    // Handle old/legacy compression (try zlib, then gzip)
    try {
      return Uint8List.fromList(zLibDecoder.decodeBytes(data));
    } catch (_) {
      try {
        return Uint8List.fromList(gZipDecoder.decodeBytes(data));
      } catch (e) {
        throw FormatException('Failed to decode LEGACY method=$method: $e');
      }
    }
  } else {
    throw UnsupportedError('Unknown compression method byte: $method');
  }
}

/// Defines both legacy and current compression method IDs.
/// Legacy ones are still recognized in [restoreBytes], but are no longer written by [shrinkBytes].
class _CompressionMethod {
  // Legacy IDs (for backward compatibility before the 1.5.6 fix)
  static const int legacyStart = 1;
  static const int legacyEnd = 9;

  static const int identity = 0;
  static const int zlib1 = 19;
  static const int zlib9 = 27;
  static const int gzip1 = 28;
  static const int gzip9 = 36;

  static bool isLegacy(int method) =>
      method >= legacyStart && method <= legacyEnd;
  static bool isZlib(int method) => method >= zlib1 && method <= zlib9;
  static bool isGzip(int method) => method >= gzip1 && method <= gzip9;
}

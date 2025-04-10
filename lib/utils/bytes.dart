import 'dart:typed_data';
import 'package:archive/archive.dart';

/// Compresses a [Uint8List] using the optimal compression method.
/// Returns a [Uint8List] with a method byte prefix followed by compressed data.
/// Compression is lossless and can be reversed with restoreBytes().
Uint8List shrinkBytes(Uint8List bytes) {
  // Start by assuming "no compression" is best (identity).
  int bestMethod = _CompressionMethod.identity;
  List<int> bestData = bytes;

  // Start attempt at zlib level 4.
  final zLibEncoder = ZLibEncoder();

  // Start at zlib level 4.
  const startLevel = 4;
  const endLevel = 9;

  try {
    // First try level 4
    final level4Result = zLibEncoder.encode(bytes, level: startLevel);
    if (level4Result.length < bestData.length) {
      // If level 4 is beneficial, adopt it and set method=10 (zlib)
      bestMethod = _CompressionMethod.zlib; // We'll always use 10
      bestData = level4Result;

      // Now try levels 5..9, but still store method=10 if improved
      for (int level = startLevel + 1; level <= endLevel; level++) {
        try {
          final encoded = zLibEncoder.encode(bytes, level: level);
          if (encoded.length < bestData.length) {
            // Update only the bestData, keep bestMethod as 10
            bestData = encoded;
          } else {
            // No improvement => stop checking further levels
            break;
          }
        } catch (_) {
          break; // If something goes wrong, keep current best
        }
      }
    }
    // If level 4 wasn't better, remain identity (0).
  } catch (_) {
    // If zlib fails at all, remain identity.
  }

  // Build the final [Uint8List]: method byte + compressed bytes
  final result = Uint8List(bestData.length + 1);
  result[0] = bestMethod;
  result.setRange(1, result.length, bestData);
  return result;
}

/// Decompresses a [Uint8List] that was compressed by [shrinkBytes].
///
/// Reads the compression method from the first byte and applies the appropriate
/// decompression algorithm. Supports legacy compression methods from versions
/// prior to 1.5.6.
///
/// Returns the original uncompressed data.
/// Throws [ArgumentError] if input is empty, [UnsupportedError] for unknown
/// compression methods, or [FormatException] if data is corrupted.
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

  if (method == _CompressionMethod.zlib) {
    return Uint8List.fromList(zLibDecoder.decodeBytes(data));
  } else if (_CompressionMethod.isLegacy(method)) {
    // Legacy 1..9 could be zlib or gzip, try zlib first, then gzip.
    try {
      return Uint8List.fromList(zLibDecoder.decodeBytes(data));
    } catch (_) {
      final gZipDecoder = GZipDecoder();
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
  static const int identity = 0;

  // Legacy range for backward compatibility
  static const int legacyStart = 1;
  static const int legacyEnd = 9;

  static const int zlib = 10;

  static bool isLegacy(int method) =>
      method >= legacyStart && method <= legacyEnd;
}

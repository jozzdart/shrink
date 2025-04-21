import 'dart:typed_data';
import 'package:archive/archive.dart';

/// Compresses a [Uint8List] using the optimal compression method.
/// Returns a [Uint8List] with a method byte prefix followed by compressed data.
/// Compression is lossless and can be reversed with restoreBytes().
Uint8List shrinkBytes(Uint8List bytes) {
  final _BestCompressionResult best = _tryZlibCompression(bytes);
  return _buildFinalResult(best.method, best.data);
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

class _BestCompressionResult {
  final int method;
  final List<int> data;
  const _BestCompressionResult(this.method, this.data);
}

/// Attempts ZLib compression across levels 4 to 9.
/// Returns the best result while keeping method ID consistent.
_BestCompressionResult _tryZlibCompression(Uint8List bytes) {
  int bestMethod = _CompressionMethod.identity;
  List<int> bestData = bytes;

  final zLibEncoder = ZLibEncoder();
  const startLevel = 4;
  const endLevel = 9;

  try {
    final level4 = zLibEncoder.encode(bytes, level: startLevel);
    if (level4.length < bestData.length) {
      bestMethod = _CompressionMethod.zlib;
      bestData = level4;

      for (int level = startLevel + 1; level <= endLevel; level++) {
        try {
          final encoded = zLibEncoder.encode(bytes, level: level);
          if (encoded.length < bestData.length) {
            bestData = encoded;
          } else {
            break;
          }
        } catch (_) {
          break;
        }
      }
    }
  } catch (_) {
    // Do nothing, fallback to identity
  }

  return _BestCompressionResult(bestMethod, bestData);
}

/// Prefixes compressed data with the method byte.
Uint8List _buildFinalResult(int method, List<int> data) {
  final result = Uint8List(data.length + 1);
  result[0] = method;
  result.setRange(1, result.length, data);
  return result;
}

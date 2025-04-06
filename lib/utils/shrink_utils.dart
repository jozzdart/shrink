import 'dart:io';
import 'dart:typed_data';
import 'encoding_utils.dart';

/// Utility class for shrink compression/decompression operations.
class ShrinkCompressor {
  /// Compresses a Uint8List using zlib.
  static Uint8List compressBytes(Uint8List input) {
    return Uint8List.fromList(zlib.encode(input));
  }

  /// Decompresses zlib-compressed data.
  static Uint8List decompressBytes(Uint8List input) {
    return Uint8List.fromList(zlib.decode(input));
  }

  /// Combines compression and base64 encoding.
  static String shrinkBytes(Uint8List data) {
    final compressed = compressBytes(data);
    return ShrinkEncoder.encodeToBase64(compressed);
  }

  /// Combines base64 decoding and decompression.
  static Uint8List unshrinkBytes(String shrunk) {
    final compressed = ShrinkEncoder.decodeFromBase64(shrunk);
    return decompressBytes(compressed);
  }

  static Uint8List compressUnique(List<int> ids) {
    final bitmask = ShrinkEncoder.encodeBitmask(ids);
    return compressBytes(bitmask);
  }

  static List<int> decompressUnique(Uint8List compressed) {
    final decompressed = decompressBytes(compressed);
    return ShrinkEncoder.decodeBitmask(decompressed);
  }

  static String shrinkUnique(List<int> ids) {
    final bitmask = ShrinkEncoder.encodeBitmask(ids);
    final compressed = compressBytes(bitmask);
    return ShrinkEncoder.encodeToBase64(compressed);
  }

  /// Full pipeline for decoding integer IDs:
  /// Base64 decode → Decompress → Convert from bitmask
  static List<int> unshrinkUnique(String encoded) {
    final compressed = ShrinkEncoder.decodeFromBase64(encoded);
    final bitmask = decompressBytes(compressed);
    return ShrinkEncoder.decodeBitmask(bitmask);
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

/// A strongly-typed result containing the decoded length and payload.
class ShrunkPayload {
  final int length;
  final Uint8List data;

  const ShrunkPayload(this.length, this.data);
}

/// Utility class for shrink encoding/decoding operations.
/// Compatible with Dart 2.19 (no pattern matching or records).
class ShrinkUtils {
  /// Adds a 4-byte Uint32 (big endian) prefix to the byte array.
  static Uint8List addLengthPrefix(Uint8List data, int length) {
    final lengthBytes = ByteData(4)..setUint32(0, length, Endian.big);
    final result = Uint8List(4 + data.length);
    result.setRange(0, 4, lengthBytes.buffer.asUint8List());
    result.setRange(4, result.length, data);
    return result;
  }

  /// Extracts the Uint32 length prefix and payload from a prefixed byte array.
  static ShrunkPayload splitLengthPrefix(Uint8List prefixed) {
    if (prefixed.length < 4) {
      throw ArgumentError('Input is too short to contain a length prefix.');
    }
    final length = ByteData.sublistView(prefixed, 0, 4).getUint32(0, Endian.big);
    final data = Uint8List.sublistView(prefixed, 4);
    return ShrunkPayload(length, data);
  }

  /// Compresses a Uint8List using zlib.
  static Uint8List compressBytes(Uint8List input) {
    return Uint8List.fromList(zlib.encode(input));
  }

  /// Decompresses zlib-compressed data.
  static Uint8List decompressBytes(Uint8List input) {
    return Uint8List.fromList(zlib.decode(input));
  }

  /// Encodes a byte array to a Base64 string (Firestore-safe).
  static String encodeToBase64(Uint8List input) {
    return base64Encode(input);
  }

  /// Decodes a Base64 string into a byte array.
  static Uint8List decodeFromBase64(String encoded) {
    return base64Decode(encoded);
  }

  static String encodeCompressed(Uint8List data) {
    final compressed = compressBytes(data);
    return encodeToBase64(compressed);
  }

  static Uint8List decodeCompressed(String encoded) {
    final compressed = decodeFromBase64(encoded);
    return decompressBytes(compressed);
  }

  /// Full pipeline: add length prefix → compress → base64 encode.
  static String encodeWithLengthPrefix(Uint8List data, int length) {
    final prefixed = addLengthPrefix(data, length);
    final compressed = compressBytes(prefixed);
    return encodeToBase64(compressed);
  }

  /// Full pipeline: base64 decode → decompress → extract length + data.
  static ShrunkPayload decodeWithLengthPrefix(String encoded) {
    final compressed = decodeFromBase64(encoded);
    final decompressed = decompressBytes(compressed);
    return splitLengthPrefix(decompressed);
  }
}

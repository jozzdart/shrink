import 'dart:typed_data';
import 'shrink_utils.dart';

/// A base class for all shrinkable data types.
/// Handles compression and encoding logic.
/// Subclasses implement [toBytes] and [fromBytes].
abstract class Shrinkable<T> {
  const Shrinkable();

  /// Converts the value to raw bytes (must be implemented by subclass).
  Uint8List toBytes(T value);

  /// Converts bytes back to the value (must be implemented by subclass).
  T fromBytes(Uint8List bytes, int originalLength);

  /// Converts a value to a compressed, Base64-encoded string.
  String encode(T value) {
    final raw = toBytes(value);
    return ShrinkUtils.encodeWithLengthPrefix(raw, raw.length);
  }

  /// Decodes a value from a Base64-encoded, compressed string.
  T decode(String encoded) {
    final payload = ShrinkUtils.decodeWithLengthPrefix(encoded);
    return fromBytes(payload.data, payload.length);
  }
}

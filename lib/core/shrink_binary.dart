import 'dart:typed_data';

/// Prepend a Uint32 (length) to a byte array
Uint8List addLengthPrefix(Uint8List bytes, int length) {
  final lengthBytes = ByteData(4)..setUint32(0, length);
  final result = Uint8List(4 + bytes.length);
  result.setAll(0, lengthBytes.buffer.asUint8List());
  result.setAll(4, bytes);
  return result;
}

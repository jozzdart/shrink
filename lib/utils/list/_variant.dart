part of 'unique.dart';

/// Encodes a sorted list of integers using delta + varint encoding.
/// Returns a Uint8List representing the encoded bytes.
Uint8List _encodeDeltaVarint(List<int> ids) {
  if (ids.isEmpty) return Uint8List(0);

  // Remove duplicates and sort
  final uniqueIds = ids.toSet().toList();
  uniqueIds.sort();

  final buffer = BytesBuilder();

  // Encode first ID directly
  _writeVarint(buffer, uniqueIds[0]);

  for (int i = 1; i < uniqueIds.length; i++) {
    final delta = uniqueIds[i] - uniqueIds[i - 1];
    _writeVarint(buffer, delta);
  }

  return buffer.toBytes();
}

/// Decodes a Uint8List encoded with delta + varint back into a list of integers.
List<int> _decodeDeltaVarint(Uint8List bytes) {
  final List<int> result = [];
  int offset = 0;

  int? last;
  while (offset < bytes.length) {
    final read = _readVarint(bytes, offset);
    final value = read.value;
    offset = read.offset;

    final original = last == null ? value : last + value;
    result.add(original);
    last = original;
  }

  return result;
}

/// Writes a single integer as a varint into the buffer.
void _writeVarint(BytesBuilder buffer, int value) {
  while (value >= 0x80) {
    buffer.addByte((value & 0x7F) | 0x80);
    value >>= 7;
  }
  buffer.addByte(value);
}

/// Reads a varint from a byte array starting at [offset].
/// Returns both the decoded value and the new offset.
_ReadVarintResult _readVarint(Uint8List bytes, int offset) {
  int value = 0;
  int shift = 0;
  int b;

  do {
    b = bytes[offset++];
    value |= (b & 0x7F) << shift;
    shift += 7;
  } while ((b & 0x80) != 0);

  return _ReadVarintResult(value, offset);
}

class _ReadVarintResult {
  final int value;
  final int offset;

  _ReadVarintResult(this.value, this.offset);
}

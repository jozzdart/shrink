part of 'unique.dart';

Uint8List _encodeChunked(List<int> ids) {
  if (ids.isEmpty) return Uint8List(0);

  // Remove duplicates and sort
  final uniqueIds = ids.toSet().toList();
  uniqueIds.sort();

  final buffer = BytesBuilder();

  final Map<int, List<int>> chunks = {};

  // Group IDs into chunks of 256
  for (final id in uniqueIds) {
    final chunkKey = id ~/ 256;
    chunks.putIfAbsent(chunkKey, () => []).add(id % 256);
  }

  for (final entry in chunks.entries) {
    final int chunkKey = entry.key;
    final List<int> localIds = entry.value;

    // Header: chunkKey
    _writeVarint(buffer, chunkKey);

    if (localIds.length >= 128) {
      // Dense: use 256-bit bitmask (32 bytes)
      buffer.addByte(0); // 0 = bitmask mode
      final chunkBitmask = Uint8List(32); // 256 bits

      for (final localId in localIds) {
        final byteIndex = localId ~/ 8;
        final bitPosition = localId % 8;
        chunkBitmask[byteIndex] |= (1 << bitPosition);
      }
      buffer.add(chunkBitmask);
    } else {
      // Sparse: use delta + varint
      buffer.addByte(1); // 1 = sparse list mode
      _writeVarint(buffer, localIds.length);
      int last = 0;
      for (int i = 0; i < localIds.length; i++) {
        final delta = i == 0 ? localIds[i] : localIds[i] - last;
        _writeVarint(buffer, delta);
        last = localIds[i];
      }
    }
  }

  return buffer.toBytes();
}

/// Decodes a chunked-encoded Uint8List back into the original list of integers.
List<int> _decodeChunked(Uint8List bytes) {
  final List<int> result = [];
  int offset = 0;

  while (offset < bytes.length) {
    // Read chunk key
    final chunkKeyResult = _readVarint(bytes, offset);
    final int chunkKey = chunkKeyResult.value;
    offset = chunkKeyResult.offset;

    // Read chunk mode
    final int mode = bytes[offset++];

    if (mode == 0) {
      // Bitmask mode
      final bitmask = bytes.sublist(offset, offset + 32);
      offset += 32;

      // Process bitmask
      for (int localId = 0; localId < 256; localId++) {
        final byteIndex = localId ~/ 8;
        final bitPosition = localId % 8;
        if ((bitmask[byteIndex] & (1 << bitPosition)) != 0) {
          result.add(chunkKey * 256 + localId);
        }
      }
    } else {
      // Sparse list mode
      final countResult = _readVarint(bytes, offset);
      final int count = countResult.value;
      offset = countResult.offset;

      int last = 0;
      for (int i = 0; i < count; i++) {
        final deltaResult = _readVarint(bytes, offset);
        final int delta = deltaResult.value;
        offset = deltaResult.offset;

        last = i == 0 ? delta : last + delta;
        result.add(chunkKey * 256 + last);
      }
    }
  }

  return result;
}

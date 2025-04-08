part of 'unique.dart';

/// Encodes a list of integers into a bitmask representation.
/// Returns a Uint8List with a 4-byte prefix indicating the length of the bitmask.
Uint8List _encodeBitmask(List<int> ids) {
  // Remove duplicates
  final uniqueIds = ids.toSet().toList();

  // Find the maximum ID to determine bitmask size
  int maxId = 0;
  for (final id in uniqueIds) {
    if (id > maxId) {
      maxId = id;
    }
  }

  // Calculate number of bytes needed (rounded up)
  final int bitsNeeded = maxId + 1;
  final int bytesNeeded = (bitsNeeded + 7) ~/ 8; // Ceiling division

  // Create a bitmask of the appropriate size
  final bitmask = Uint8List(bytesNeeded);

  // Set bits for each ID
  for (final id in uniqueIds) {
    final int byteIndex = id ~/ 8;
    final int bitPosition = id % 8;
    bitmask[byteIndex] |= (1 << bitPosition);
  }

  // Create the result with a 4-byte length prefix for the bit length
  final result = Uint8List(4 + bitmask.length);
  ByteData.view(result.buffer).setUint32(0, bitsNeeded, Endian.big);
  result.setRange(4, result.length, bitmask);

  return result;
}

/// Decodes a bitmask representation into a list of integers.
/// The input should have a 4-byte prefix indicating the length of the bitmask.
List<int> _decodeBitmask(Uint8List bytes) {
  // Extract the bit length from the first 4 bytes
  final bitLength = ByteData.view(bytes.buffer, bytes.offsetInBytes, 4)
      .getUint32(0, Endian.big);

  // The rest of the bytes are the bitmask
  final bitmask = Uint8List.sublistView(bytes, 4);

  // Convert bitmask back to a list of IDs
  final List<int> ids = [];

  for (int id = 0; id < bitLength; id++) {
    final int byteIndex = id ~/ 8;
    final int bitPosition = id % 8;

    // Check if this ID's bit is set
    if (byteIndex < bitmask.length &&
        (bitmask[byteIndex] & (1 << bitPosition)) != 0) {
      ids.add(id);
    }
  }

  return ids;
}

part of 'unique.dart';

/// Encodes a sorted list of integers using skip-run (0s-1s) compression.
/// Useful for sparse data with long gaps.
Uint8List _encodeRuns(List<int> ids) {
  if (ids.isEmpty) return Uint8List(0);

  // Remove duplicates and sort
  final uniqueIds = ids.toSet().toList();
  uniqueIds.sort();

  final buffer = BytesBuilder();

  int last = -1;

  for (int i = 0; i < uniqueIds.length;) {
    final int skip = uniqueIds[i] - (last + 1);
    _writeVarint(buffer, skip);

    int runLength = 1;
    last = uniqueIds[i];

    while (i + runLength < uniqueIds.length && uniqueIds[i + runLength] == uniqueIds[i + runLength - 1] + 1) {
      last = uniqueIds[i + runLength];
      runLength++;
    }

    _writeVarint(buffer, runLength);
    i += runLength;
  }

  return buffer.toBytes();
}

/// Decodes a skip-run compressed Uint8List back into the original list of integers.
List<int> _decodeRuns(Uint8List bytes) {
  final List<int> result = [];
  int offset = 0;
  int current = -1;

  while (offset < bytes.length) {
    final skipResult = _readVarint(bytes, offset);
    offset = skipResult.offset;

    // Calculate next value after skipping
    current = current + skipResult.value + 1;
    int startValue = current;

    final runResult = _readVarint(bytes, offset);
    offset = runResult.offset;
    final int runLength = runResult.value;

    // Add consecutive values for this run
    for (int i = 0; i < runLength; i++) {
      result.add(startValue + i);
    }

    // Update current to the last value in this run
    current = startValue + runLength - 1;
  }

  return result;
}

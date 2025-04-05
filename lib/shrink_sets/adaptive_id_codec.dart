// File: lib/core/adaptive_id_codec.dart

import 'dart:io';
import 'dart:typed_data';

class CompressConfig {
  final int start;
  final int multiplier;

  const CompressConfig({
    this.start = 1,
    this.multiplier = 4,
  });
}

/// A simple container for a consecutive run of IDs.
class _Run {
  final int start;
  final int length;
  _Run(this.start, this.length);
}

// Writes an unsigned varint (7 bits per byte, top bit = continuation).
void _writeUnsignedVarint(List<int> out, int value) {
  if (value < 0) {
    throw ArgumentError('Cannot encode negative varint \$value');
  }
  while (true) {
    // Lower 7 bits
    final part = value & 0x7F;
    value >>= 7;
    if (value == 0) {
      // Stop
      out.add(part); // MSB=0
      break;
    } else {
      // More bytes coming
      out.add(part | 0x80); // MSB=1
    }
  }
}

/// Reads an unsigned varint from [data], starting at [offset].
/// Returns an object containing the decoded value and new offset.
class _VarintResult {
  final int value;
  final int offset;
  _VarintResult(this.value, this.offset);
}

_VarintResult _readUnsignedVarint(Uint8List data, int offset) {
  int result = 0;
  int shift = 0;

  while (true) {
    if (offset >= data.length) {
      throw FormatException('Varint extends past end of data.');
    }
    final byte = data[offset++];
    final chunk = byte & 0x7F;
    result |= (chunk << shift);
    shift += 7;

    // If MSB=0, stop.
    if ((byte & 0x80) == 0) {
      return _VarintResult(result, offset);
    }

    // Prevent overly large shift
    if (shift > 35) {
      throw FormatException('Varint is too large/corrupt.');
    }
  }
}

/// Compress a list of integer IDs by turning them into
/// `[runCount, (start, length), (start, length), ...]` varints, then zlib.
Uint8List compressAdaptiveIdList(List<int> input, CompressConfig config) {
  if (input.isEmpty) {
    return Uint8List(0);
  }

  // 1. Sort unique IDs
  final sortedIds = input.toSet().toList()..sort();

  // 2. Find consecutive runs
  final runs = <_Run>[];
  int runStart = sortedIds[0];
  int prev = runStart;
  int runLength = 1;

  for (int i = 1; i < sortedIds.length; i++) {
    final current = sortedIds[i];
    if (current == prev + 1) {
      // Continue the run
      runLength++;
    } else {
      // End previous run, start new run
      runs.add(_Run(runStart, runLength));
      runStart = current;
      runLength = 1;
    }
    prev = current;
  }
  // Add the final run
  runs.add(_Run(runStart, runLength));

  // 3. Encode all runs as varints
  final bytes = <int>[];
  // how many runs
  _writeUnsignedVarint(bytes, runs.length);

  // each run => (start, length)
  for (final run in runs) {
    _writeUnsignedVarint(bytes, run.start);
    _writeUnsignedVarint(bytes, run.length);
  }

  // 4. zlib compress
  return Uint8List.fromList(zlib.encode(bytes));
}

/// Decompress IDs from the `[runCount, (start, length), ...]` varint + zlib format.
List<int> decompressAdaptiveIdList(Uint8List compressed, CompressConfig config) {
  if (compressed.isEmpty) {
    return [];
  }

  // 1. zlib decode
  final decoded = zlib.decode(compressed);
  final data = Uint8List.fromList(decoded);

  // 2. Read how many runs
  int offset = 0;
  final runCountResult = _readUnsignedVarint(data, offset);
  final runCount = runCountResult.value;
  offset = runCountResult.offset;
  if (runCount == 0) {
    return [];
  }

  final results = <int>[];
  // 3. For each run => read (start, length)
  for (int i = 0; i < runCount; i++) {
    final startResult = _readUnsignedVarint(data, offset);
    final start = startResult.value;
    offset = startResult.offset;

    final lengthResult = _readUnsignedVarint(data, offset);
    final length = lengthResult.value;
    offset = lengthResult.offset;

    // Expand the run
    for (int k = 0; k < length; k++) {
      results.add(start + k);
    }
  }
  return results;
}

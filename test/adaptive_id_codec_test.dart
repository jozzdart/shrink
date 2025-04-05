import 'dart:math';
import 'dart:typed_data';
import 'package:test/test.dart';

// Import your updated run-length + varint + zlib code:
import 'package:shrink/shrink_sets/adaptive_id_codec.dart';

/// Create a raw bitmask of which IDs are present.
/// - [ids] is a list of integer IDs (e.g., [1, 10, 11]).
/// - Returns a [Uint8List] of bytes. If [ids] is empty, returns an empty list.
/// - The bit for ID `n` is set if and only if `n` is in [ids].
Uint8List toBitmask(List<int> ids) {
  if (ids.isEmpty) return Uint8List(0);

  final maxId = ids.reduce(max);
  // total bits needed = maxId + 1 (covering 0..maxId)
  final lengthInBits = maxId + 1;
  final lengthInBytes = (lengthInBits + 7) >> 3; // divide by 8, round up
  final buffer = List<int>.filled(lengthInBytes, 0);

  for (final id in ids) {
    final byteIndex = id >> 3; // id / 8
    final bitPosition = id & 0x07; // id % 8
    buffer[byteIndex] |= (1 << bitPosition);
  }

  return Uint8List.fromList(buffer);
}

/// Decode a raw bitmask back into a list of integer IDs.
List<int> fromBitmask(Uint8List bitmask) {
  final results = <int>[];
  for (int byteIndex = 0; byteIndex < bitmask.length; byteIndex++) {
    final b = bitmask[byteIndex];
    if (b == 0) continue; // no bits set in this byte
    for (int bitPosition = 0; bitPosition < 8; bitPosition++) {
      if ((b & (1 << bitPosition)) != 0) {
        results.add((byteIndex << 3) + bitPosition);
      }
    }
  }
  return results;
}

void main() {
  group('Adaptive ID Codec', () {
    final random = Random();

    // Generate up to 'size' IDs with large random gaps.
    List<int> generateSparseList(int size) {
      final result = <int>[];
      int current = 0;
      for (int i = 0; i < size; i++) {
        current += random.nextInt(1000) + 1; // random gap 1..1000
        result.add(current);
      }
      return result;
    }

    // Generate up to 'size' IDs all in one consecutive cluster.
    List<int> generateClusteredList(int size) {
      final result = <int>[];
      int start = random.nextInt(5000);
      for (int i = 0; i < size; i++) {
        result.add(start + i);
      }
      return result;
    }

    // Generate up to 'size' IDs with partial consecutive segments and some jumps.
    List<int> generateMixedList(int size) {
      final result = <int>[];
      int current = random.nextInt(500);
      for (int i = 0; i < size; i++) {
        // 50% chance just +1, else big jump
        if (random.nextBool()) {
          current += 1;
        } else {
          current += random.nextInt(500) + 1;
        }
        result.add(current);
      }
      return result;
    }

    // Print only summary stats instead of the full list.
    void printListSummary(String description, List<int> list) {
      final unique = list.toSet();
      final sorted = unique.toList()..sort();
      final length = list.length;
      final minVal = sorted.isEmpty ? 0 : sorted.first;
      final maxVal = sorted.isEmpty ? 0 : sorted.last;
      print('\n--- Test: $description ---');
      print('  Count: $length, Unique: ${unique.length}, '
          'Min: $minVal, Max: $maxVal');
      // Optionally show first 5 & last 5 elements
      if (length <= 10) {
        print('  Values: $sorted');
      } else {
        print('  First 5: ${sorted.take(5).toList()} '
            '... Last 5: ${sorted.skip(length - 5).toList()}');
      }
    }

    // A helper that runs a single test: compress -> decompress -> verify -> measure
    void testRoundTrip(String description, List<int> list, CompressConfig config) {
      test(description, () {
        // Print a short summary of the input
        printListSummary(description, list);

        // (A) Compressed approach: compress -> decompress
        final startTime = DateTime.now().microsecondsSinceEpoch;
        final encoded = compressAdaptiveIdList(list, config);
        final midTime = DateTime.now().microsecondsSinceEpoch;
        final decoded = decompressAdaptiveIdList(encoded, config);
        final endTime = DateTime.now().microsecondsSinceEpoch;

        // (B) Raw bitmask approach: build bitmask
        final bitmask = toBitmask(list);
        // We could decode it: final bitmaskDecoded = fromBitmask(bitmask);

        // Compute some metrics
        final maxId = list.isEmpty ? 0 : list.reduce(max);
        final uncompressedBytes = ((maxId + 1) / 8).ceil(); // theoretical bitmask size
        final compressedBytes = encoded.length;
        final bitmaskBytes = bitmask.length;
        final savedPercent = uncompressedBytes == 0 ? 0 : 100 - ((compressedBytes / uncompressedBytes) * 100);

        // Print performance & compression stats
        final compressTime = midTime - startTime; // microseconds
        final decompressTime = endTime - midTime; // microseconds
        print('  Compressed size: $compressedBytes bytes');
        print('  Raw bitmask size: $bitmaskBytes bytes');
        print('  Theoretical uncompressed bitmask: $uncompressedBytes bytes');
        print('  Space saved vs. theoretical: ${savedPercent.toStringAsFixed(2)}%');
        print('  Compression time: $compressTimeµs');
        print('  Decompression time: $decompressTimeµs');

        // Validate correctness: must match original
        expect(decoded.toSet(), equals(list.toSet()));
        // If you also decode the bitmask, you can verify that as well:
        // expect(bitmaskDecoded.toSet(), list.toSet());
      });
    }

    // Vary the size. For example, test small (30), medium (300), large (3000).
    final sizes = [30, 300, 3000];

    // We can also loop multiple times with different random seeds.
    for (int i = 0; i < 3; i++) {
      for (final size in sizes) {
        // We still keep config for compatibility, though we might not use it.
        final config = CompressConfig(
          start: [1, 2, 4, 8][random.nextInt(4)],
          multiplier: [2, 4, 8][random.nextInt(3)],
        );
        testRoundTrip('Sparse Set (size=$size, iteration=$i)', generateSparseList(size), config);
        testRoundTrip('Clustered Set (size=$size, iteration=$i)', generateClusteredList(size), config);
        testRoundTrip('Mixed Set (size=$size, iteration=$i)', generateMixedList(size), config);
      }
    }
  });
}

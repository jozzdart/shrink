import 'package:test/test.dart';
import 'package:shrink/utils/list/methods/chunked.dart';

import '../list_test_data_generator.dart';

void main() {
  group('Chunked List Compression Tests', () {
    test('encodeChunked and decodeChunked work with empty list', () {
      final emptyList = <int>[];

      final encoded = encodeChunked(emptyList);
      final decoded = decodeChunked(encoded);

      expect(decoded, equals(emptyList));
    });

    test('encodeChunked and decodeChunked work with single value', () {
      final singleValue = [42];

      final encoded = encodeChunked(singleValue);
      final decoded = decodeChunked(encoded);

      expect(decoded, equals(singleValue));
    });

    test('encodeChunked and decodeChunked work with small sorted list', () {
      final smallList = [1, 5, 10, 15, 20];

      final encoded = encodeChunked(smallList);
      final decoded = decodeChunked(encoded);

      expect(decoded, equals(smallList));
    });

    test('encodeChunked and decodeChunked work with unsorted input', () {
      final unsortedList = [20, 5, 15, 1, 10];
      final sortedList = [1, 5, 10, 15, 20];

      final encoded = encodeChunked(unsortedList);
      final decoded = decodeChunked(encoded);

      // Chunked encoding sorts the list
      expect(decoded, equals(sortedList));
    });

    test('encodeChunked removes duplicates', () {
      final listWithDuplicates = [1, 5, 5, 10, 10, 10, 20];
      final uniqueList = [1, 5, 10, 20]; // Duplicates removed and sorted

      final encoded = encodeChunked(listWithDuplicates);
      final decoded = decodeChunked(encoded);

      // Verify that duplicates were removed
      expect(decoded, equals(uniqueList));
    });

    test('encodeChunked and decodeChunked work with dense chunk (bitmask mode)', () {
      // Create a list with 150 values in the same chunk (0-255 range)
      // This should trigger the bitmask mode
      final denseChunkList = List.generate(150, (i) => i + 50);

      final encoded = encodeChunked(denseChunkList);
      final decoded = decodeChunked(encoded);

      expect(decoded, equals(denseChunkList));
    });

    test('encodeChunked and decodeChunked work with sparse chunk (list mode)', () {
      // Create a list with only a few values in the same chunk
      // This should trigger the sparse list mode
      final sparseChunkList = [50, 75, 100, 125, 150];

      final encoded = encodeChunked(sparseChunkList);
      final decoded = decodeChunked(encoded);

      expect(decoded, equals(sparseChunkList));
    });

    test('encodeChunked and decodeChunked work with multiple chunks', () {
      // Create a list with values spanning multiple chunks
      final multiChunkList = [
        50, 100, 200, // chunk 0
        300, 350, 400, 450, // chunk 1
        700, 750, 800 // chunk 2-3
      ];

      final encoded = encodeChunked(multiChunkList);
      final decoded = decodeChunked(encoded);

      expect(decoded, equals(multiChunkList));
    });

    test('encodeChunked and decodeChunked work with sparse list', () {
      final sparseList = ListTestDataGenerator.generateSparseList(size: 100, sparsity: 50.0);

      final encoded = encodeChunked(sparseList);
      final decoded = decodeChunked(encoded);

      expect(decoded, equals(sparseList));
    });

    test('encodeChunked and decodeChunked work with chunked list', () {
      final chunkedList = ListTestDataGenerator.generateChunkedList(size: 200, chunkSize: 10, gapRatio: 5.0);

      final encoded = encodeChunked(chunkedList);
      final decoded = decodeChunked(encoded);

      expect(decoded, equals(chunkedList));
    });

    test('encodeChunked works with large values', () {
      // Create a list with very large values spanning many chunks
      final largeValuesList = List.generate(100, (i) => i * 1000 + 10000);

      final encoded = encodeChunked(largeValuesList);
      final decoded = decodeChunked(encoded);

      expect(decoded, equals(largeValuesList));
    });

    test('chunked encoding compresses data with multiple test cases', () {
      final testCases = [
        ListTestDataGenerator.generateSortedUniqueList(size: 1000, maxValue: 10000),
        ListTestDataGenerator.generateSparseList(size: 2000, sparsity: 10.0),
        ListTestDataGenerator.generateChunkedList(size: 3000, chunkSize: 50, gapRatio: 2.0),
        ListTestDataGenerator.generateSortedUniqueList(size: 5000, maxValue: 50000),
        ListTestDataGenerator.generateSortedUniqueList(size: 10000, maxValue: 100000),
      ];

      for (final testCase in testCases) {
        final encoded = encodeChunked(testCase);
        final decoded = decodeChunked(encoded);

        expect(decoded, equals(testCase), reason: 'Failed with list of size ${testCase.length}');
      }
    });

    test('chunked encoding performance with increasing sparsity', () {
      final sparsityFactors = [2.0, 5.0, 10.0, 20.0, 50.0, 100.0];
      final testSeries = ListTestDataGenerator.generateSparsenessSeries(
        size: 5000,
        sparsityFactors: sparsityFactors,
      );

      for (int i = 0; i < testSeries.length; i++) {
        final testCase = testSeries[i];
        final sparsity = sparsityFactors[i];

        final encoded = encodeChunked(testCase);
        final decoded = decodeChunked(encoded);

        expect(decoded, equals(testCase), reason: 'Failed with sparsity factor $sparsity');
      }
    });

    test('chunked encoding performance with different chunk sizes', () {
      final chunkSizes = [5, 10, 20, 50, 100];
      final testSeries = ListTestDataGenerator.generateChunkSizeSeries(
        size: 5000,
        chunkSizes: chunkSizes,
        gapRatio: 2.0,
      );

      for (int i = 0; i < testSeries.length; i++) {
        final testCase = testSeries[i];
        final chunkSize = chunkSizes[i];

        final encoded = encodeChunked(testCase);
        final decoded = decodeChunked(encoded);

        expect(decoded, equals(testCase), reason: 'Failed with chunk size $chunkSize');
      }
    });
  });
}

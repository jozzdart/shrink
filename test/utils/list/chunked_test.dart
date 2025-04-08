import 'package:test/test.dart';
import 'package:shrink/utils/list/unique.dart';

import '../list_test_data_generator.dart';

void main() {
  group('Chunked List Compression Tests', () {
    test('chunked compression works with empty list', () {
      final emptyList = <int>[];

      final encoded = shrinkUniqueManual(emptyList, UniqueCompressionMethod.chunked);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(emptyList));
    });

    test('chunked compression works with single value', () {
      final singleValue = [42];

      final encoded = shrinkUniqueManual(singleValue, UniqueCompressionMethod.chunked);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(singleValue));
    });

    test('chunked compression works with small sorted list', () {
      final smallList = [1, 5, 10, 15, 20];

      final encoded = shrinkUniqueManual(smallList, UniqueCompressionMethod.chunked);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(smallList));
    });

    test('chunked compression works with unsorted input', () {
      final unsortedList = [20, 5, 15, 1, 10];
      final sortedList = [1, 5, 10, 15, 20];

      final encoded = shrinkUniqueManual(unsortedList, UniqueCompressionMethod.chunked);
      final decoded = restoreUnique(encoded);

      // Chunked encoding sorts the list
      expect(decoded, equals(sortedList));
    });

    test('chunked compression removes duplicates', () {
      final listWithDuplicates = [1, 5, 5, 10, 10, 10, 20];
      final uniqueList = [1, 5, 10, 20]; // Duplicates removed and sorted

      final encoded = shrinkUniqueManual(listWithDuplicates, UniqueCompressionMethod.chunked);
      final decoded = restoreUnique(encoded);

      // Verify that duplicates were removed
      expect(decoded, equals(uniqueList));
    });

    test('chunked compression works with dense chunk list', () {
      // Create a list with 150 values in the same chunk
      final denseChunkList = List.generate(150, (i) => i + 50);

      final encoded = shrinkUniqueManual(denseChunkList, UniqueCompressionMethod.chunked);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(denseChunkList));
    });

    test('chunked compression works with sparse chunk list', () {
      // Create a list with only a few values in the same chunk
      final sparseChunkList = [50, 75, 100, 125, 150];

      final encoded = shrinkUniqueManual(sparseChunkList, UniqueCompressionMethod.chunked);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(sparseChunkList));
    });

    test('chunked compression works with multiple chunks', () {
      // Create a list with values spanning multiple chunks
      final multiChunkList = [
        50, 100, 200, // chunk 0
        300, 350, 400, 450, // chunk 1
        700, 750, 800 // chunk 2-3
      ];

      final encoded = shrinkUniqueManual(multiChunkList, UniqueCompressionMethod.chunked);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(multiChunkList));
    });

    test('chunked compression works with sparse list', () {
      final sparseList = ListTestDataGenerator.generateSparseList(size: 100, sparsity: 50.0);

      final encoded = shrinkUniqueManual(sparseList, UniqueCompressionMethod.chunked);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(sparseList));
    });

    test('chunked compression works with chunked list', () {
      final chunkedList = ListTestDataGenerator.generateChunkedList(size: 200, chunkSize: 10, gapRatio: 5.0);

      final encoded = shrinkUniqueManual(chunkedList, UniqueCompressionMethod.chunked);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(chunkedList));
    });

    test('chunked compression works with large values', () {
      // Create a list with very large values spanning many chunks
      final largeValuesList = List.generate(100, (i) => i * 1000 + 10000);

      final encoded = shrinkUniqueManual(largeValuesList, UniqueCompressionMethod.chunked);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(largeValuesList));
    });

    test('chunked compression compresses data with multiple test cases', () {
      final testCases = [
        ListTestDataGenerator.generateSortedUniqueList(size: 1000, maxValue: 10000),
        ListTestDataGenerator.generateSparseList(size: 2000, sparsity: 10.0),
        ListTestDataGenerator.generateChunkedList(size: 3000, chunkSize: 50, gapRatio: 2.0),
        ListTestDataGenerator.generateSortedUniqueList(size: 5000, maxValue: 50000),
        ListTestDataGenerator.generateSortedUniqueList(size: 10000, maxValue: 100000),
      ];

      for (final testCase in testCases) {
        final encoded = shrinkUniqueManual(testCase, UniqueCompressionMethod.chunked);
        final decoded = restoreUnique(encoded);

        expect(decoded, equals(testCase), reason: 'Failed with list of size ${testCase.length}');
      }
    });

    test('chunked compression performance with increasing sparsity', () {
      final sparsityFactors = [2.0, 5.0, 10.0, 20.0, 50.0, 100.0];
      final testSeries = ListTestDataGenerator.generateSparsenessSeries(
        size: 5000,
        sparsityFactors: sparsityFactors,
      );

      for (int i = 0; i < testSeries.length; i++) {
        final testCase = testSeries[i];
        final sparsity = sparsityFactors[i];

        final encoded = shrinkUniqueManual(testCase, UniqueCompressionMethod.chunked);
        final decoded = restoreUnique(encoded);

        expect(decoded, equals(testCase), reason: 'Failed with sparsity factor $sparsity');
      }
    });

    test('chunked compression performance with different chunk sizes', () {
      final chunkSizes = [5, 10, 20, 50, 100];
      final testSeries = ListTestDataGenerator.generateChunkSizeSeries(
        size: 5000,
        chunkSizes: chunkSizes,
        gapRatio: 2.0,
      );

      for (int i = 0; i < testSeries.length; i++) {
        final testCase = testSeries[i];
        final chunkSize = chunkSizes[i];

        final encoded = shrinkUniqueManual(testCase, UniqueCompressionMethod.chunked);
        final decoded = restoreUnique(encoded);

        expect(decoded, equals(testCase), reason: 'Failed with chunk size $chunkSize');
      }
    });
  });
}

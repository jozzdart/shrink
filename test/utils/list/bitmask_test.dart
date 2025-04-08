import 'package:test/test.dart';
import 'package:shrink/utils/list/unique.dart';

import '../list_test_data_generator.dart';

void main() {
  group('Bitmask List Compression Tests', () {
    test('bitmask compression works with empty list', () {
      final emptyList = <int>[];

      final encoded =
          shrinkUniqueManual(emptyList, UniqueCompressionMethod.bitmask);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(emptyList));
    });

    test('bitmask compression works with small list', () {
      final smallList = [1, 5, 10, 15, 20];

      final encoded =
          shrinkUniqueManual(smallList, UniqueCompressionMethod.bitmask);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(smallList));
    });

    test('bitmask compression works with single value', () {
      final singleValue = [42];

      final encoded =
          shrinkUniqueManual(singleValue, UniqueCompressionMethod.bitmask);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(singleValue));
    });

    test('bitmask compression works with large consecutive values', () {
      final largeValues = List.generate(100, (i) => i * 10);

      final encoded =
          shrinkUniqueManual(largeValues, UniqueCompressionMethod.bitmask);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(largeValues));
    });

    test('bitmask compression works with sparse list', () {
      final sparseList =
          ListTestDataGenerator.generateSparseList(size: 100, sparsity: 50.0);

      final encoded =
          shrinkUniqueManual(sparseList, UniqueCompressionMethod.bitmask);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(sparseList));
    });

    test('bitmask compression works with chunked list', () {
      final chunkedList = ListTestDataGenerator.generateChunkedList(
          size: 200, chunkSize: 10, gapRatio: 5.0);

      final encoded =
          shrinkUniqueManual(chunkedList, UniqueCompressionMethod.bitmask);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(chunkedList));
    });

    test('bitmask compression works with unsorted input', () {
      final unsortedList = [20, 5, 15, 1, 10];
      final sortedList = [1, 5, 10, 15, 20];

      final encoded =
          shrinkUniqueManual(unsortedList, UniqueCompressionMethod.bitmask);
      final decoded = restoreUnique(encoded);

      // Bitmask doesn't care about order - it just records presence
      expect(decoded, equals(sortedList));
    });

    test('bitmask compression removes duplicates', () {
      final listWithDuplicates = [1, 5, 5, 10, 10, 10, 20];
      final uniqueList = [1, 5, 10, 20];

      final encoded = shrinkUniqueManual(
          listWithDuplicates, UniqueCompressionMethod.bitmask);
      final decoded = restoreUnique(encoded);

      // Verify that duplicates were removed
      expect(decoded, equals(uniqueList));
    });

    test('bitmask compresses data with multiple test cases', () {
      final testCases = [
        ListTestDataGenerator.generateSortedUniqueList(
            size: 1000, maxValue: 10000),
        ListTestDataGenerator.generateSparseList(size: 2000, sparsity: 10.0),
        ListTestDataGenerator.generateChunkedList(
            size: 3000, chunkSize: 50, gapRatio: 2.0),
        ListTestDataGenerator.generateSortedUniqueList(
            size: 5000, maxValue: 50000),
        ListTestDataGenerator.generateSortedUniqueList(
            size: 10000, maxValue: 100000),
      ];

      for (final testCase in testCases) {
        final encoded =
            shrinkUniqueManual(testCase, UniqueCompressionMethod.bitmask);
        final decoded = restoreUnique(encoded);

        expect(decoded, equals(testCase),
            reason: 'Failed with list of size ${testCase.length}');
      }
    });

    test('bitmask performance with increasing sparsity', () {
      final sparsityFactors = [2.0, 5.0, 10.0, 20.0, 50.0, 100.0];
      final testSeries = ListTestDataGenerator.generateSparsenessSeries(
        size: 5000,
        sparsityFactors: sparsityFactors,
      );

      for (int i = 0; i < testSeries.length; i++) {
        final testCase = testSeries[i];
        final sparsity = sparsityFactors[i];

        final encoded =
            shrinkUniqueManual(testCase, UniqueCompressionMethod.bitmask);
        final decoded = restoreUnique(encoded);

        expect(decoded, equals(testCase),
            reason: 'Failed with sparsity factor $sparsity');
      }
    });
  });
}

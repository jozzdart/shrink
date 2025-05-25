import 'package:test/test.dart';
import 'package:shrink/shrink.dart';

import '../list_test_data_generator.dart';

void main() {
  group('Run-Length List Compression Tests', () {
    test('runlength compression works with empty list', () {
      final emptyList = <int>[];

      final encoded =
          shrinkUniqueManual(emptyList, UniqueCompressionMethod.runLength);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(emptyList));
    });

    test('runlength compression works with single value', () {
      final singleValue = [42];

      final encoded =
          shrinkUniqueManual(singleValue, UniqueCompressionMethod.runLength);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(singleValue));
    });

    test('runlength compression works with small sorted list', () {
      final smallList = [1, 5, 10, 15, 20];

      final encoded =
          shrinkUniqueManual(smallList, UniqueCompressionMethod.runLength);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(smallList));
    });

    test('runlength compression works with unsorted input', () {
      final unsortedList = [20, 5, 15, 1, 10];
      final sortedList = [1, 5, 10, 15, 20];

      final encoded =
          shrinkUniqueManual(unsortedList, UniqueCompressionMethod.runLength);
      final decoded = restoreUnique(encoded);

      // Run-length encoding sorts the list
      expect(decoded, equals(sortedList));
    });

    test('runlength compression works with sequential values', () {
      final sequentialList = List.generate(100, (i) => i);

      final encoded =
          shrinkUniqueManual(sequentialList, UniqueCompressionMethod.runLength);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(sequentialList));
    });

    test('runlength compression works with consecutive runs', () {
      final listWithRuns = [
        1, 2, 3, 4, 5, // First run
        10, 11, 12, 13, 14, 15, // Second run
        20, 21, 22, // Third run
        30 // Single value
      ];

      final encoded =
          shrinkUniqueManual(listWithRuns, UniqueCompressionMethod.runLength);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(listWithRuns));
    });

    test('runlength compression removes duplicates', () {
      // List with duplicates
      final listWithDuplicates = [1, 3, 3, 5, 7, 7, 10];
      final expectedList = [1, 3, 5, 7, 10]; // Duplicates removed and sorted

      final encoded = shrinkUniqueManual(
          listWithDuplicates, UniqueCompressionMethod.runLength);
      final decoded = restoreUnique(encoded);

      // Verify that duplicates were removed
      expect(decoded, equals(expectedList));
    });

    test('runlength compression works with sparse list', () {
      final sparseList =
          ListTestDataGenerator.generateSparseList(size: 100, sparsity: 50.0);

      final encoded =
          shrinkUniqueManual(sparseList, UniqueCompressionMethod.runLength);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(sparseList));
    });

    test('runlength compression works with chunked list', () {
      final chunkedList = ListTestDataGenerator.generateChunkedList(
          size: 200, chunkSize: 10, gapRatio: 5.0);

      final encoded =
          shrinkUniqueManual(chunkedList, UniqueCompressionMethod.runLength);
      final decoded = restoreUnique(encoded);

      expect(decoded, equals(chunkedList));
    });

    test('runlength compression works with multiple test cases', () {
      final testCases = [
        ListTestDataGenerator.generateSortedUniqueList(
            size: 1000, maxValue: 10000),
        ListTestDataGenerator.generateSparseList(size: 2000, sparsity: 10.0),
        ListTestDataGenerator.generateChunkedList(
            size: 3000, chunkSize: 50, gapRatio: 2.0),
      ];

      for (final testCase in testCases) {
        final encoded =
            shrinkUniqueManual(testCase, UniqueCompressionMethod.runLength);
        final decoded = restoreUnique(encoded);

        expect(decoded, equals(testCase));
      }
    });

    test('runlength compression performance with increasing sparsity', () {
      final sparsityFactors = [2.0, 5.0, 10.0];
      final testSeries = ListTestDataGenerator.generateSparsenessSeries(
        size: 1000, // Using a smaller size for quicker tests
        sparsityFactors: sparsityFactors,
      );

      for (int i = 0; i < testSeries.length; i++) {
        final testCase = testSeries[i];

        final encoded =
            shrinkUniqueManual(testCase, UniqueCompressionMethod.runLength);
        final decoded = restoreUnique(encoded);

        expect(decoded, equals(testCase));
      }
    });

    test('runlength compression performance with different chunk sizes', () {
      final chunkSizes = [5, 10, 20];
      final testSeries = ListTestDataGenerator.generateChunkSizeSeries(
        size: 1000, // Using a smaller size for quicker tests
        chunkSizes: chunkSizes,
        gapRatio: 2.0,
      );

      for (int i = 0; i < testSeries.length; i++) {
        final testCase = testSeries[i];

        final encoded =
            shrinkUniqueManual(testCase, UniqueCompressionMethod.runLength);
        final decoded = restoreUnique(encoded);

        expect(decoded, equals(testCase));
      }
    });
  });
}

import 'package:test/test.dart';
import 'package:shrink/utils/list/methods/runlength.dart';

import '../list_test_data_generator.dart';

void main() {
  group('Run-Length List Compression Tests', () {
    test('encodeRuns and decodeRuns work with empty list', () {
      final emptyList = <int>[];

      final encoded = encodeRuns(emptyList);
      final decoded = decodeRuns(encoded);

      expect(decoded, equals(emptyList));
    });

    test('encodeRuns and decodeRuns work with single value', () {
      final singleValue = [42];

      final encoded = encodeRuns(singleValue);
      final decoded = decodeRuns(encoded);

      expect(decoded, equals(singleValue));
    });

    test('encodeRuns and decodeRuns work with small sorted list', () {
      final smallList = [1, 5, 10, 15, 20];

      final encoded = encodeRuns(smallList);
      final decoded = decodeRuns(encoded);

      expect(decoded, equals(smallList));
    });

    test('encodeRuns and decodeRuns work with unsorted input', () {
      final unsortedList = [20, 5, 15, 1, 10];
      final sortedList = [1, 5, 10, 15, 20];

      final encoded = encodeRuns(unsortedList);
      final decoded = decodeRuns(encoded);

      // Run-length encoding sorts the list
      expect(decoded, equals(sortedList));
    });

    test('encodeRuns and decodeRuns work with sequential values', () {
      final sequentialList = List.generate(100, (i) => i);

      final encoded = encodeRuns(sequentialList);
      final decoded = decodeRuns(encoded);

      expect(decoded, equals(sequentialList));
    });

    test('encodeRuns and decodeRuns work with consecutive runs', () {
      final listWithRuns = [
        1, 2, 3, 4, 5, // First run
        10, 11, 12, 13, 14, 15, // Second run
        20, 21, 22, // Third run
        30 // Single value
      ];

      final encoded = encodeRuns(listWithRuns);
      final decoded = decodeRuns(encoded);

      expect(decoded, equals(listWithRuns));
    });

    test('encodeRuns removes duplicates', () {
      // List with duplicates
      final listWithDuplicates = [1, 3, 3, 5, 7, 7, 10];
      final expectedList = [1, 3, 5, 7, 10]; // Duplicates removed and sorted

      final encoded = encodeRuns(listWithDuplicates);
      final decoded = decodeRuns(encoded);

      // Verify that duplicates were removed
      expect(decoded, equals(expectedList));
    });

    test('encodeRuns and decodeRuns work with sparse list', () {
      final sparseList = ListTestDataGenerator.generateSparseList(size: 100, sparsity: 50.0);

      final encoded = encodeRuns(sparseList);
      final decoded = decodeRuns(encoded);

      expect(decoded, equals(sparseList));
    });

    test('encodeRuns and decodeRuns work with chunked list', () {
      final chunkedList = ListTestDataGenerator.generateChunkedList(size: 200, chunkSize: 10, gapRatio: 5.0);

      final encoded = encodeRuns(chunkedList);
      final decoded = decodeRuns(encoded);

      expect(decoded, equals(chunkedList));
    });

    test('encodeRuns compresses data with multiple test cases', () {
      final testCases = [
        ListTestDataGenerator.generateSortedUniqueList(size: 1000, maxValue: 10000),
        ListTestDataGenerator.generateSparseList(size: 2000, sparsity: 10.0),
        ListTestDataGenerator.generateChunkedList(size: 3000, chunkSize: 50, gapRatio: 2.0),
      ];

      for (final testCase in testCases) {
        final encoded = encodeRuns(testCase);
        final decoded = decodeRuns(encoded);

        expect(decoded, equals(testCase));
      }
    });

    test('encodeRuns performance with increasing sparsity', () {
      final sparsityFactors = [2.0, 5.0, 10.0];
      final testSeries = ListTestDataGenerator.generateSparsenessSeries(
        size: 1000, // Using a smaller size for quicker tests
        sparsityFactors: sparsityFactors,
      );

      for (int i = 0; i < testSeries.length; i++) {
        final testCase = testSeries[i];

        final encoded = encodeRuns(testCase);
        final decoded = decodeRuns(encoded);

        expect(decoded, equals(testCase));
      }
    });

    test('encodeRuns performance with different chunk sizes', () {
      final chunkSizes = [5, 10, 20];
      final testSeries = ListTestDataGenerator.generateChunkSizeSeries(
        size: 1000, // Using a smaller size for quicker tests
        chunkSizes: chunkSizes,
        gapRatio: 2.0,
      );

      for (int i = 0; i < testSeries.length; i++) {
        final testCase = testSeries[i];

        final encoded = encodeRuns(testCase);
        final decoded = decodeRuns(encoded);

        expect(decoded, equals(testCase));
      }
    });
  });
}

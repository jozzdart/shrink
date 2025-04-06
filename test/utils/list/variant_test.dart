import 'package:test/test.dart';
import 'package:shrink/utils/list/methods/variant.dart';

import '../list_test_data_generator.dart';

void main() {
  group('Delta-Varint List Compression Tests', () {
    test('encodeDeltaVarint and decodeDeltaVarint work with empty list', () {
      final emptyList = <int>[];

      final encoded = encodeDeltaVarint(emptyList);
      final decoded = decodeDeltaVarint(encoded);

      expect(decoded, equals(emptyList));
    });

    test('encodeDeltaVarint and decodeDeltaVarint work with single value', () {
      final singleValue = [42];

      final encoded = encodeDeltaVarint(singleValue);
      final decoded = decodeDeltaVarint(encoded);

      expect(decoded, equals(singleValue));
    });

    test('encodeDeltaVarint and decodeDeltaVarint work with small sorted list', () {
      final smallList = [1, 5, 10, 15, 20];

      final encoded = encodeDeltaVarint(smallList);
      final decoded = decodeDeltaVarint(encoded);

      expect(decoded, equals(smallList));
    });

    test('encodeDeltaVarint and decodeDeltaVarint work with unsorted input', () {
      final unsortedList = [20, 5, 15, 1, 10];
      final sortedList = [1, 5, 10, 15, 20];

      final encoded = encodeDeltaVarint(unsortedList);
      final decoded = decodeDeltaVarint(encoded);

      // Delta encoding sorts the list
      expect(decoded, equals(sortedList));
    });

    test('encodeDeltaVarint removes duplicates', () {
      final listWithDuplicates = [1, 5, 5, 10, 10, 10, 20];
      final uniqueList = [1, 5, 10, 20]; // Duplicates removed and sorted

      final encoded = encodeDeltaVarint(listWithDuplicates);
      final decoded = decodeDeltaVarint(encoded);

      // Verify that duplicates were removed
      expect(decoded, equals(uniqueList));
    });

    test('encodeDeltaVarint and decodeDeltaVarint work with sequential values', () {
      final sequentialList = List.generate(100, (i) => i);

      final encoded = encodeDeltaVarint(sequentialList);
      final decoded = decodeDeltaVarint(encoded);

      expect(decoded, equals(sequentialList));
    });

    test('encodeDeltaVarint and decodeDeltaVarint work with sparse list', () {
      final sparseList = ListTestDataGenerator.generateSparseList(size: 100, sparsity: 50.0);

      final encoded = encodeDeltaVarint(sparseList);
      final decoded = decodeDeltaVarint(encoded);

      expect(decoded, equals(sparseList));
    });

    test('encodeDeltaVarint and decodeDeltaVarint work with chunked list', () {
      final chunkedList = ListTestDataGenerator.generateChunkedList(size: 200, chunkSize: 10, gapRatio: 5.0);

      final encoded = encodeDeltaVarint(chunkedList);
      final decoded = decodeDeltaVarint(encoded);

      expect(decoded, equals(chunkedList));
    });

    test('deltaVarint compresses data with multiple test cases', () {
      final testCases = [
        ListTestDataGenerator.generateSortedUniqueList(size: 1000, maxValue: 10000),
        ListTestDataGenerator.generateSparseList(size: 2000, sparsity: 10.0),
        ListTestDataGenerator.generateChunkedList(size: 3000, chunkSize: 50, gapRatio: 2.0),
        ListTestDataGenerator.generateSortedUniqueList(size: 5000, maxValue: 50000),
        ListTestDataGenerator.generateSortedUniqueList(size: 10000, maxValue: 100000),
      ];

      for (final testCase in testCases) {
        final encoded = encodeDeltaVarint(testCase);
        final decoded = decodeDeltaVarint(encoded);

        expect(decoded, equals(testCase), reason: 'Failed with list of size ${testCase.length}');
      }
    });

    test('deltaVarint performance with increasing sparsity', () {
      final sparsityFactors = [2.0, 5.0, 10.0, 20.0, 50.0, 100.0];
      final testSeries = ListTestDataGenerator.generateSparsenessSeries(
        size: 5000,
        sparsityFactors: sparsityFactors,
      );

      for (int i = 0; i < testSeries.length; i++) {
        final testCase = testSeries[i];
        final sparsity = sparsityFactors[i];

        final encoded = encodeDeltaVarint(testCase);
        final decoded = decodeDeltaVarint(encoded);

        expect(decoded, equals(testCase), reason: 'Failed with sparsity factor $sparsity');
      }
    });

    test('deltaVarint performance with different chunk sizes', () {
      final chunkSizes = [5, 10, 20, 50, 100];
      final testSeries = ListTestDataGenerator.generateChunkSizeSeries(
        size: 5000,
        chunkSizes: chunkSizes,
        gapRatio: 2.0,
      );

      for (int i = 0; i < testSeries.length; i++) {
        final testCase = testSeries[i];
        final chunkSize = chunkSizes[i];

        final encoded = encodeDeltaVarint(testCase);
        final decoded = decodeDeltaVarint(encoded);

        expect(decoded, equals(testCase), reason: 'Failed with chunk size $chunkSize');
      }
    });
  });
}

import 'package:test/test.dart';
import 'package:shrink/utils/list/unique.dart';
import 'package:shrink/utils/list/methods/methods.dart';

import '../list_test_data_generator.dart';

void main() {
  group('Unique List Compression Tests', () {
    test('shrinkUnique and restoreUnique work with empty list', () {
      final emptyList = <int>[];

      final compressed = shrinkUnique(emptyList);
      final restored = restoreUnique(compressed);

      expect(restored, equals(emptyList));
    });

    test('shrinkUnique and restoreUnique work with single value', () {
      final singleValue = [42];

      final compressed = shrinkUnique(singleValue);
      final restored = restoreUnique(compressed);

      expect(restored, equals(singleValue));
    });

    test('shrinkUnique and restoreUnique work with small sorted list', () {
      final smallList = [1, 5, 10, 15, 20];

      final compressed = shrinkUnique(smallList);
      final restored = restoreUnique(compressed);

      expect(restored, equals(smallList));
    });

    test('shrinkUnique and restoreUnique work with unsorted input', () {
      final unsortedList = [20, 5, 15, 1, 10];
      final sortedList = [1, 5, 10, 15, 20];

      final compressed = shrinkUnique(unsortedList);
      final restored = restoreUnique(compressed);

      // Result should be sorted regardless of input order
      expect(restored, equals(sortedList));
    });

    test('shrinkUnique removes duplicates', () {
      final listWithDuplicates = [1, 5, 5, 10, 10, 10, 20];
      final uniqueList = [1, 5, 10, 20]; // Duplicates removed and sorted

      final compressed = shrinkUnique(listWithDuplicates);
      final restored = restoreUnique(compressed);

      expect(restored, equals(uniqueList));
    });

    test('shrinkUnique and restoreUnique preserve data with various test cases', () {
      final testCases = [
        // Sequential values (should favor Run-Length encoding)
        List.generate(1000, (i) => i),

        // Sparse data (DeltaVarint might be better)
        ListTestDataGenerator.generateSparseList(size: 1000, sparsity: 50.0),

        // Chunked data (Chunked encoding might win)
        ListTestDataGenerator.generateChunkedList(size: 1000, chunkSize: 10, gapRatio: 5.0),

        // Large values in a small range (Bitmask might win)
        List.generate(200, (i) => i * 2 + 1000),

        // Large list with wide distribution
        ListTestDataGenerator.generateSortedUniqueList(size: 5000, maxValue: 100000),
      ];

      for (final testCase in testCases) {
        final compressed = shrinkUnique(testCase);
        final restored = restoreUnique(compressed);

        expect(restored, equals(testCase), reason: 'Failed with list of size ${testCase.length}');
      }
    });

    test('shrinkUnique selects the best compression method', () {
      // Test cases optimized for different methods
      final testCasesByExpectedMethod = {
        // Sequential values - Run-Length should win
        UniqueCompressionMethod.runLength: List.generate(1000, (i) => i),

        // Sparse, non-sequential values - DeltaVarint should be competitive
        UniqueCompressionMethod.deltaVarint: ListTestDataGenerator.generateSparseList(size: 1000, sparsity: 20.0),

        // Values clustered in ranges - Chunked should be competitive
        UniqueCompressionMethod.chunked: List.generate(1000, (i) => (i ~/ 10) * 256 + (i % 10)),

        // Very large max value but few values - Bitmask should win
        UniqueCompressionMethod.bitmask: List.generate(100, (i) => i * 100).take(50).toList(),
      };

      // Verify each test case selects the expected method
      testCasesByExpectedMethod.forEach((expectedMethod, testCase) {
        final compressed = shrinkUnique(testCase);
        final methodIndex = compressed[0];
        final selectedMethod = UniqueCompressionMethod.values[methodIndex];

        // Get sizes from all methods for debugging/comparison
        final sizes = _getCompressionSizes(testCase);
        // Calculate no shrink size (4 bytes per integer)
        final noShrinkSize = testCase.length * 4;

        print('Test case optimized for ${expectedMethod.name}:');
        print('  No shrink size: $noShrinkSize bytes');
        sizes.forEach((method, size) => print('  ${method.name}: $size bytes'));
        print('  Selected: ${selectedMethod.name}');

        // Check if expected method was selected or if a better one was found
        if (selectedMethod != expectedMethod) {
          // If a different method was selected, make sure it's actually better
          final expectedSize = sizes[expectedMethod]!;
          final selectedSize = sizes[selectedMethod]!;

          expect(selectedSize <= expectedSize, isTrue,
              reason: 'Selected ${selectedMethod.name} ($selectedSize bytes) '
                  'over ${expectedMethod.name} ($expectedSize bytes)');
        }

        // Verify restoration works correctly
        final restored = restoreUnique(compressed);
        expect(restored, equals(testCase));
      });
    });

    test('shrinkUnique compresses better than individual methods in some cases', () {
      // Create a mixed test case that might benefit from different methods in different parts
      final mixedTestCase = [
        ...List.generate(100, (i) => i), // Sequential (good for Run-Length)
        ...List.generate(100, (i) => 1000 + i * 25), // Sparse (good for DeltaVarint)
        ...List.generate(100, (i) => 10000 + (i ~/ 10) * 256 + (i % 10)), // Chunked pattern
      ];

      final uniqueCompressed = shrinkUnique(mixedTestCase);

      // Calculate no shrink size (4 bytes per integer)
      final noShrinkSize = mixedTestCase.length * 4;

      // Compare against individual methods
      final methodSizes = {
        'No shrink': noShrinkSize,
        'DeltaVarint': encodeDeltaVarint(mixedTestCase).length,
        'RunLength': encodeRuns(mixedTestCase).length,
        'Chunked': encodeChunked(mixedTestCase).length,
        'Bitmask': encodeBitmask(mixedTestCase).length,
        'UniqueCompression': uniqueCompressed.length,
      };

      // Print sizes for analysis
      print('\nCompression sizes for mixed data:');
      print('| Method            | Shrink size (bytes) | Compression Ratio |');
      print('|-------------------|---------------------|-------------------|');

      methodSizes.forEach((method, size) {
        final ratio = method == 'No shrink' ? '100.00%' : '${((size / noShrinkSize) * 100).toStringAsFixed(2)}%';
        print('| ${method.padRight(17)} | ${size.toString().padRight(19)} | ${ratio.padRight(17)} |');
      });

      // Check that UniqueCompression is better than or equal to individual methods
      final uniqueSize = methodSizes['UniqueCompression']!;
      final bestIndividualSize =
          methodSizes.entries.where((e) => !['UniqueCompression', 'No shrink'].contains(e.key)).map((e) => e.value).reduce((a, b) => a < b ? a : b);

      // Unique has 1 byte overhead for method index
      expect(uniqueSize <= bestIndividualSize + 1, isTrue,
          reason: 'UniqueCompression ($uniqueSize bytes) should be '
              'close to or better than best individual method ($bestIndividualSize bytes)');

      // Verify restoration works correctly
      final restored = restoreUnique(uniqueCompressed);
      expect(restored, equals(mixedTestCase));
    });

    test('shrinkUnique performance with different data distributions', () {
      // Test with various data distributions
      final distributions = [
        _DistributionInfo('Sequential', List.generate(1000, (i) => i)),
        _DistributionInfo('Sparse-Low', ListTestDataGenerator.generateSparseList(size: 1000, sparsity: 5.0)),
        _DistributionInfo('Sparse-High', ListTestDataGenerator.generateSparseList(size: 1000, sparsity: 50.0)),
        _DistributionInfo('Chunked-Small', ListTestDataGenerator.generateChunkedList(size: 1000, chunkSize: 5, gapRatio: 2.0)),
        _DistributionInfo('Chunked-Large', ListTestDataGenerator.generateChunkedList(size: 1000, chunkSize: 50, gapRatio: 2.0)),
        _DistributionInfo('Random', ListTestDataGenerator.generateSortedUniqueList(size: 1000, maxValue: 10000)),
      ];

      print('\nCompression performance by data distribution:');
      print('| Distribution | No shrink size | Shrink size | Compression Ratio | Selected Method |');
      print('|--------------|----------------|-------------|-------------------|----------------|');

      for (final dist in distributions) {
        final compressed = shrinkUnique(dist.data);
        final methodIndex = compressed[0];
        final method = UniqueCompressionMethod.values[methodIndex].name;

        // Calculate compression ratio (original is 4 bytes per int)
        final noShrinkSize = dist.data.length * 4;
        final ratio = compressed.length / noShrinkSize;

        print('| ${dist.name.padRight(12)} | '
            '${noShrinkSize.toString().padRight(14)} | '
            '${compressed.length.toString().padRight(11)} | '
            '${(ratio * 100).toStringAsFixed(2).padRight(17)}% | '
            '${method.padRight(14)} |');

        // Verify restoration works
        final restored = restoreUnique(compressed);
        expect(restored, equals(dist.data));
      }
    });
  });
}

/// Helper class to track test data distribution info
class _DistributionInfo {
  final String name;
  final List<int> data;

  _DistributionInfo(this.name, this.data);
}

/// Helper function to get sizes from all compression methods for a given list
Map<UniqueCompressionMethod, int> _getCompressionSizes(List<int> ids) {
  final sortedIds = [...ids]..sort();

  return {
    UniqueCompressionMethod.deltaVarint: encodeDeltaVarint(sortedIds).length,
    UniqueCompressionMethod.runLength: encodeRuns(sortedIds).length,
    UniqueCompressionMethod.chunked: encodeChunked(sortedIds).length,
    UniqueCompressionMethod.bitmask: encodeBitmask(sortedIds).length,
  };
}

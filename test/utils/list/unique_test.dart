import 'package:test/test.dart';
import 'package:shrink/utils/list/unique.dart';
import 'dart:typed_data';

import '../list_test_data_generator.dart';
import '../../logs/logs.dart';

// Set to false to disable logging in tests
const bool enableLogging = false;

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

      var logger = LogsGroup.empty();

      testCasesByExpectedMethod.forEach((expectedMethod, testCase) {
        final compressed = shrinkUnique(testCase);
        final methodIndex = compressed[0];
        final selectedMethod = UniqueCompressionMethod.values[methodIndex];

        // Get sizes from all methods for debugging/comparison
        final sizes = _getCompressionSizes(testCase);
        // Calculate no shrink size (4 bytes per integer)
        final noShrinkSize = testCase.length * 4;

        // Create dataset for logging
        final dataset = DatasetInfo(
          'Optimized for ${expectedMethod.name}',
          testCase,
          'Testing compression method selection',
        );

        // Create results for all methods
        final results = <CompressionResult>[];

        // Add "No shrink" baseline
        results.add(CompressionResult(
          methodName: 'No Shrink',
          originalSize: noShrinkSize,
          compressedSize: noShrinkSize,
          correct: true,
        ));

        // Add results for each method
        for (final entry in sizes.entries) {
          results.add(CompressionResult(
            methodName: entry.key.name,
            originalSize: noShrinkSize,
            compressedSize: entry.value,
            correct: true,
          ));
        }

        // Add the actual selected method
        results.add(CompressionResult(
          methodName: 'Selected: ${selectedMethod.name}',
          originalSize: noShrinkSize,
          compressedSize: compressed.length,
          correct: true,
        ));

        // Log the compression results
        var logs = CompressionLogger.logCompressionResults(
          dataset: dataset,
          results: results,
        );

        logger.addLogs(logs);

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

      // Print all logs at the end of the test case
      if (enableLogging) {
        logger.printAll();
      }
    });

    test('shrinkUnique compresses better than individual methods in some cases', () {
      var logger = LogsGroup.empty();

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
        'DeltaVarint': shrinkUniqueManual(mixedTestCase, UniqueCompressionMethod.deltaVarint).length,
        'RunLength': shrinkUniqueManual(mixedTestCase, UniqueCompressionMethod.runLength).length,
        'Chunked': shrinkUniqueManual(mixedTestCase, UniqueCompressionMethod.chunked).length,
        'Bitmask': shrinkUniqueManual(mixedTestCase, UniqueCompressionMethod.bitmask).length,
        'UniqueCompression': uniqueCompressed.length,
      };

      // Format data for table logging

      // Create dataset info
      final dataset = DatasetInfo(
        'Mixed Data Compression Test',
        mixedTestCase,
        'Testing compression methods with mixed data patterns',
      );

      // Create compression results
      final results = <CompressionResult>[];

      // Add each method as a CompressionResult
      methodSizes.forEach((methodName, size) {
        results.add(CompressionResult(
          methodName: methodName,
          originalSize: noShrinkSize,
          compressedSize: size,
          correct: true,
        ));
      });

      // Log the compression results
      var logs = CompressionLogger.logCompressionResults(
        dataset: dataset,
        results: results,
      );

      logger.addLogs(logs);

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

      // Print all logs at the end of the test case
      if (enableLogging) {
        logger.printAll();
      }
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

      var logger = LogsGroup.empty();

      // Create datasets and results for all distributions
      final datasets = <DatasetInfo>[];
      final allResults = <DatasetInfo, List<CompressionResult>>{};

      for (final dist in distributions) {
        final dataset = DatasetInfo(
          dist.name,
          dist.data,
          'Data distribution test',
        );
        datasets.add(dataset);

        final compressed = shrinkUnique(dist.data);
        final methodIndex = compressed[0];
        final method = UniqueCompressionMethod.values[methodIndex].name;

        // Calculate compression ratio (original is 4 bytes per int)
        final noShrinkSize = dist.data.length * 4;

        // Create the result
        final results = <CompressionResult>[
          CompressionResult(
            methodName: method,
            originalSize: noShrinkSize,
            compressedSize: compressed.length,
            correct: true,
          ),
        ];

        allResults[dataset] = results;

        // Verify restoration works
        final restored = restoreUnique(compressed);
        expect(restored, equals(dist.data));
      }

      // Log all results
      var table = CompressionLogger.logMultipleDatasetResults(
        datasets: datasets,
        allResults: allResults,
      );

      logger.addLogs(table);

      // Print all logs at the end of the test case
      if (enableLogging) {
        logger.printAll();
      }
    });

    test('shrinkUnique with very large list (250k items)', () {
      // Create test cases with 250,000 unique items
      final hugeLists = [
        _DistributionInfo(
          'Mega-Sequential',
          List.generate(250000, (i) => i).toSet().toList(),
        ),
        _DistributionInfo(
          'Mega-Sparse',
          ListTestDataGenerator.generateSparseList(size: 250000, sparsity: 50.0),
        ),
      ];

      var logger = LogsGroup.empty();

      for (final hugeList in hugeLists) {
        final dataset = DatasetInfo(
          hugeList.name,
          hugeList.data,
          'Testing compression with 250,000 unique items',
        );

        final stopwatch = Stopwatch()..start();
        final compressed = shrinkUnique(hugeList.data);
        final compressionTime = stopwatch.elapsedMilliseconds;

        stopwatch.reset();
        stopwatch.start();
        final restored = restoreUnique(compressed);
        final decompressionTime = stopwatch.elapsedMilliseconds;
        stopwatch.stop();

        final methodIndex = compressed[0];
        final method = UniqueCompressionMethod.values[methodIndex].name;

        // Calculate compression ratio
        final noShrinkSize = hugeList.data.length * 4;
        final compressionRatio = noShrinkSize / compressed.length;

        final results = <CompressionResult>[
          CompressionResult(
            methodName: method,
            originalSize: noShrinkSize,
            compressedSize: compressed.length,
            correct: true,
          ),
        ];

        var logs = CompressionLogger.logCompressionResults(
          dataset: dataset,
          results: results,
        );

        logger.addLogs(logs);
        // Print the performance metadata separately
        logger.addLogs([
          'Performance: Compression time: ${compressionTime}ms | Decompression time: ${decompressionTime}ms | Ratio: ${compressionRatio.toStringAsFixed(2)}x'
        ]);

        // Verify restoration works
        expect(restored, equals(hugeList.data));
      }

      if (enableLogging) {
        logger.printAll();
      }
    });

    test('shrinkUnique with large integer values', () {
      // Test with very large integer values
      final largeValueLists = [
        _DistributionInfo('Large-Sequential', List.generate(1000, (i) => i + 1000000)),
        _DistributionInfo('Large-Sparse', ListTestDataGenerator.generateSparseList(size: 1000, sparsity: 10.0).map((i) => i + 1000000).toList()),
        _DistributionInfo('VeryLarge-Values', List.generate(1000, (i) => i * 10000 + 1000000)),
      ];

      var logger = LogsGroup.empty();
      final datasets = <DatasetInfo>[];
      final allResults = <DatasetInfo, List<CompressionResult>>{};

      for (final list in largeValueLists) {
        final dataset = DatasetInfo(
          list.name,
          list.data,
          'Testing compression with large integer values',
        );
        datasets.add(dataset);

        final compressed = shrinkUnique(list.data);
        final methodIndex = compressed[0];
        final method = UniqueCompressionMethod.values[methodIndex].name;

        // Calculate compression ratio
        final noShrinkSize = list.data.length * 4;

        final results = <CompressionResult>[
          CompressionResult(
            methodName: method,
            originalSize: noShrinkSize,
            compressedSize: compressed.length,
            correct: true,
          ),
        ];

        allResults[dataset] = results;

        // Verify restoration works
        final restored = restoreUnique(compressed);
        expect(restored, equals(list.data));
      }

      var table = CompressionLogger.logMultipleDatasetResults(
        datasets: datasets,
        allResults: allResults,
      );

      logger.addLogs(table);

      if (enableLogging) {
        logger.printAll();
      }
    });

    test('shrinkUnique with special patterns', () {
      // Test with special patterns that might challenge compression algorithms
      final specialPatternLists = [
        // All identical values
        _DistributionInfo('All-Same', List.filled(1000, 42)),

        // Alternating pattern (even/odd)
        _DistributionInfo('Alternating', List.generate(1000, (i) => i % 2 == 0 ? 0 : 1)),

        // Fibonacci sequence
        _DistributionInfo('Fibonacci', (() {
          final result = <int>[0, 1];
          for (int i = 2; i < 20; i++) {
            result.add(result[i - 1] + result[i - 2]);
          }
          return result;
        })()),

        // Power of 2 sequence
        _DistributionInfo('PowersOf2', List.generate(10, (i) => 1 << i)),

        // Prime numbers
        _DistributionInfo('Primes', (() {
          final primes = <int>[];
          outer:
          for (int i = 2; primes.length < 10; i++) {
            for (int j = 2; j <= (i / j); j++) {
              if (i % j == 0) continue outer;
            }
            primes.add(i);
          }
          return primes;
        })()),
      ];

      var logger = LogsGroup.empty();
      final datasets = <DatasetInfo>[];
      final allResults = <DatasetInfo, List<CompressionResult>>{};

      for (final list in specialPatternLists) {
        final dataset = DatasetInfo(
          list.name,
          list.data,
          'Testing compression with special data patterns',
        );
        datasets.add(dataset);

        // Test all methods for these special cases
        final compressed = {
          'Auto-Selected': shrinkUnique(list.data),
          'DeltaVarint': shrinkUniqueManual(list.data, UniqueCompressionMethod.deltaVarint),
          'RunLength': shrinkUniqueManual(list.data, UniqueCompressionMethod.runLength),
          'Chunked': shrinkUniqueManual(list.data, UniqueCompressionMethod.chunked),
          'Bitmask': shrinkUniqueManual(list.data, UniqueCompressionMethod.bitmask),
        };

        // Calculate compression ratio
        final noShrinkSize = list.data.length * 4;

        final results = <CompressionResult>[];

        // Add "No shrink" baseline
        results.add(CompressionResult(
          methodName: 'No Shrink',
          originalSize: noShrinkSize,
          compressedSize: noShrinkSize,
          correct: true,
        ));

        // Add results for each method
        compressed.forEach((methodName, data) {
          // Verify restoration works
          final restored = restoreUnique(data);
          final isCorrect = listEquals(restored, list.data.toSet().toList());

          results.add(CompressionResult(
            methodName: methodName,
            originalSize: noShrinkSize,
            compressedSize: data.length,
            correct: isCorrect,
          ));
        });

        allResults[dataset] = results;
      }

      var table = CompressionLogger.logMultipleDatasetResults(
        datasets: datasets,
        allResults: allResults,
      );

      logger.addLogs(table);

      if (enableLogging) {
        logger.printAll();
      }
    });

    test('shrinkUnique with mixed compression-friendly datasets', () {
      // Create complex datasets that mix different patterns
      final complexDatasets = [
        // Mixed sequential and sparse
        _DistributionInfo('Mixed-SeqSparse', (() {
          final result = <int>[];
          // Add sequential blocks
          for (int i = 0; i < 5; i++) {
            final start = i * 1000;
            result.addAll(List.generate(200, (j) => start + j));
          }
          // Add sparse blocks
          result.addAll(ListTestDataGenerator.generateSparseList(size: 500, sparsity: 50.0).map((i) => i + 10000).toList());
          return result..sort();
        })()),

        // Mixed with different densities
        _DistributionInfo('Mixed-Density', (() {
          final result = <int>[];
          // Dense section
          result.addAll(List.generate(500, (i) => i));
          // Medium density
          result.addAll(List.generate(500, (i) => 1000 + i * 2));
          // Sparse section
          result.addAll(List.generate(500, (i) => 5000 + i * 10));
          // Very sparse section
          result.addAll(List.generate(500, (i) => 20000 + i * 100));
          return result;
        })()),

        // Real-world simulation: IDs
        _DistributionInfo('Simulated-IDs', (() {
          final result = <int>[];
          // Some sequential IDs (like auto-increment)
          result.addAll(List.generate(1000, (i) => 1000 + i));
          // Some clustered IDs (like created around the same time)
          for (int i = 0; i < 5; i++) {
            final base = 10000 + i * 1000;
            result.addAll(List.generate(200, (j) => base + (j * 2) + (j % 5)));
          }
          // Some random IDs
          result.addAll(ListTestDataGenerator.generateSortedUniqueList(size: 1000, maxValue: 100000));
          return result..sort();
        })()),

        // Multi-modal distribution
        _DistributionInfo('Multi-Modal', (() {
          final result = <int>[];
          // Create peaks at different places
          for (int center in [1000, 5000, 20000, 100000]) {
            // Add values clustered around center
            for (int i = 0; i < 300; i++) {
              result.add(center + (i ~/ 3) - 50);
            }
          }
          return result..sort();
        })()),
      ];

      var logger = LogsGroup.empty();
      final datasets = <DatasetInfo>[];
      final allResults = <DatasetInfo, List<CompressionResult>>{};

      for (final dataset in complexDatasets) {
        final datasetInfo = DatasetInfo(
          dataset.name,
          dataset.data,
          'Testing compression with complex mixed datasets',
        );
        datasets.add(datasetInfo);

        // Test all methods to compare
        final methodResults = <String, Uint8List>{
          'Auto-Selected': shrinkUnique(dataset.data),
          'DeltaVarint': shrinkUniqueManual(dataset.data, UniqueCompressionMethod.deltaVarint),
          'RunLength': shrinkUniqueManual(dataset.data, UniqueCompressionMethod.runLength),
          'Chunked': shrinkUniqueManual(dataset.data, UniqueCompressionMethod.chunked),
          'Bitmask': shrinkUniqueManual(dataset.data, UniqueCompressionMethod.bitmask),
        };

        // Calculate no shrink size
        final noShrinkSize = dataset.data.length * 4;

        final results = <CompressionResult>[];

        // Add baseline
        results.add(CompressionResult(
          methodName: 'No Shrink',
          originalSize: noShrinkSize,
          compressedSize: noShrinkSize,
          correct: true,
        ));

        // Add results for each method
        methodResults.forEach((methodName, data) {
          final restored = restoreUnique(data);
          final isCorrect = listEquals(restored, dataset.data.toSet().toList());

          results.add(CompressionResult(
            methodName: methodName,
            originalSize: noShrinkSize,
            compressedSize: data.length,
            correct: isCorrect,
          ));
        });

        allResults[datasetInfo] = results;
      }

      var table = CompressionLogger.logMultipleDatasetResults(
        datasets: datasets,
        allResults: allResults,
      );

      logger.addLogs(table);

      if (enableLogging) {
        logger.printAll();
      }
    });

    test('shrinkUnique with extremely large lists', () {
      // Test compression with much larger lists
      final largeLists = [
        _DistributionInfo('Huge-Sequential', List.generate(50000, (i) => i).toSet().toList()),
        _DistributionInfo('Huge-Random', ListTestDataGenerator.generateSortedUniqueList(size: 50000, maxValue: 1000000)),
        _DistributionInfo('Huge-Sparse', ListTestDataGenerator.generateSparseList(size: 25000, sparsity: 100.0)),
        _DistributionInfo('Huge-Chunked', ListTestDataGenerator.generateChunkedList(size: 25000, chunkSize: 200, gapRatio: 3.0)),
      ];

      var logger = LogsGroup.empty();
      final datasets = <DatasetInfo>[];
      final allResults = <DatasetInfo, List<CompressionResult>>{};

      for (final list in largeLists) {
        final dataset = DatasetInfo(
          list.name,
          list.data,
          'Testing compression performance with very large lists',
        );
        datasets.add(dataset);

        final compressed = shrinkUnique(list.data);
        final methodIndex = compressed[0];
        final method = UniqueCompressionMethod.values[methodIndex].name;

        // Calculate compression ratio
        final noShrinkSize = list.data.length * 4;

        final results = <CompressionResult>[
          CompressionResult(
            methodName: method,
            originalSize: noShrinkSize,
            compressedSize: compressed.length,
            correct: true,
          ),
        ];

        allResults[dataset] = results;

        // Verify restoration works
        final restored = restoreUnique(compressed);
        expect(restored, equals(list.data));
      }

      var table = CompressionLogger.logMultipleDatasetResults(
        datasets: datasets,
        allResults: allResults,
      );

      logger.addLogs(table);

      if (enableLogging) {
        logger.printAll();
      }
    });
  });
}

/// Helper function to compare lists
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
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
    UniqueCompressionMethod.deltaVarint: shrinkUniqueManual(sortedIds, UniqueCompressionMethod.deltaVarint).length,
    UniqueCompressionMethod.runLength: shrinkUniqueManual(sortedIds, UniqueCompressionMethod.runLength).length,
    UniqueCompressionMethod.chunked: shrinkUniqueManual(sortedIds, UniqueCompressionMethod.chunked).length,
    UniqueCompressionMethod.bitmask: shrinkUniqueManual(sortedIds, UniqueCompressionMethod.bitmask).length,
  };
}

import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:shrink/utils/bytes.dart';

import '../generators/generators.dart';
import '../logs/logs.dart';

// Set to false to disable logging in tests
const bool enableLogging = true;

/// Helper class to track test data information
class _BytesTestInfo {
  final String name;
  final Uint8List data;

  _BytesTestInfo(this.name, this.data);
}

void main() {
  group('Bytes Utils Tests', () {
    test('shrinkBytes and restoreBytes work with empty bytes', () {
      final emptyBytes = Uint8List(0);

      final shrunken = shrinkBytes(emptyBytes);
      final restored = restoreBytes(shrunken);

      expect(restored, equals(emptyBytes));
    });

    test('shrinkBytes and restoreBytes work with small bytes', () {
      final smallBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      final shrunken = shrinkBytes(smallBytes);
      final restored = restoreBytes(shrunken);

      expect(restored, equals(smallBytes));
    });

    test('shrinkBytes and restoreBytes work with sequential bytes', () {
      final sequentialBytes = Uint8List.fromList(List.generate(100, (i) => i % 256));

      final shrunken = shrinkBytes(sequentialBytes);
      final restored = restoreBytes(shrunken);

      expect(restored, equals(sequentialBytes));
    });

    test('shrinkBytes and restoreBytes work with random bytes', () {
      final randomBytesVar = randomBytes(500);

      final shrunken = shrinkBytes(randomBytesVar);
      final restored = restoreBytes(shrunken);

      expect(restored, equals(randomBytesVar));
    });

    test('shrinkBytes compresses repetitive data efficiently', () {
      var logger = LogsGroup.empty();

      // Create highly compressible data (repetitive)
      final repetitiveBytes = Uint8List.fromList(List.generate(1000, (i) => i % 10) // Only 10 unique values repeating
          );

      final shrunken = shrinkBytes(repetitiveBytes);

      // Create dataset info for logging
      final dataset = DatasetInfo(
        'Repetitive Data',
        repetitiveBytes.toList(), // Convert to List<int>
        'Testing compression of repetitive data',
      );

      // Calculate no compression baseline size
      final noShrinkSize = repetitiveBytes.length;

      // Create compression results
      final results = <CompressionResult>[
        CompressionResult(
          methodName: 'No Compression',
          originalSize: noShrinkSize,
          compressedSize: noShrinkSize,
          correct: true,
        ),
        CompressionResult(
          methodName: 'zlib',
          originalSize: noShrinkSize,
          compressedSize: shrunken.length,
          correct: true,
        ),
      ];

      // Log the compression results
      var logs = CompressionLogger.logCompressionResults(
        dataset: dataset,
        results: results,
      );

      logger.addLogs(logs);

      // Print all logs at the end of the test case
      if (enableLogging) {
        logger.printAll();
      }

      // Verify significant compression for repetitive data
      expect(shrunken.length, lessThan(repetitiveBytes.length / 2));
    });

    test('shrinkBytes gives minimal compression for random data', () {
      var logger = LogsGroup.empty();

      // Create random data (hardly compressible)
      final randomBytesVar = randomBytes(1000);

      final shrunken = shrinkBytes(randomBytesVar);

      // Create dataset info for logging
      final dataset = DatasetInfo(
        'Random Data',
        randomBytesVar.toList(), // Convert to List<int>
        'Testing compression of random data',
      );

      // Calculate no compression baseline size
      final noShrinkSize = randomBytesVar.length;

      // Create compression results
      final results = <CompressionResult>[
        CompressionResult(
          methodName: 'No Compression',
          originalSize: noShrinkSize,
          compressedSize: noShrinkSize,
          correct: true,
        ),
        CompressionResult(
          methodName: 'zlib',
          originalSize: noShrinkSize,
          compressedSize: shrunken.length,
          correct: true,
        ),
      ];

      // Log the compression results
      var logs = CompressionLogger.logCompressionResults(
        dataset: dataset,
        results: results,
      );

      logger.addLogs(logs);

      // Print all logs at the end of the test case
      if (enableLogging) {
        logger.printAll();
      }

      // For truly random data, compression might not be very effective
      // But with zlib overhead, it shouldn't be much larger than the original
      expect(shrunken.length, lessThanOrEqualTo(randomBytesVar.length * 1.1));
    });

    test('shrinkBytes and restoreBytes with multiple test data patterns', () {
      var logger = LogsGroup.empty();

      // Create various test datasets with different compression characteristics
      final testDataSet = [
        _BytesTestInfo('Sequential', Uint8List.fromList(List.generate(1000, (i) => i % 256))),
        _BytesTestInfo('Repetitive', Uint8List.fromList(List.generate(1000, (i) => i % 10))),
        _BytesTestInfo('Random', randomBytes(1000)),
        _BytesTestInfo('Alternating', Uint8List.fromList(List.generate(1000, (i) => i % 2 == 0 ? 0 : 255))),
        _BytesTestInfo('Mostly-Zeros', Uint8List.fromList(List.generate(1000, (i) => i < 950 ? 0 : i % 256))),
      ];

      final datasets = <DatasetInfo>[];
      final allResults = <DatasetInfo, List<CompressionResult>>{};

      for (final testData in testDataSet) {
        final dataset = DatasetInfo(
          testData.name,
          testData.data.toList(),
          'Testing compression with ${testData.name} data pattern',
        );
        datasets.add(dataset);

        final shrunken = shrinkBytes(testData.data);
        final restored = restoreBytes(shrunken);

        // Verify restoration works correctly
        expect(restored, equals(testData.data), reason: 'Failed to restore bytes of length ${testData.data.length}');

        // Calculate no compression baseline size
        final noShrinkSize = testData.data.length;

        // Create compression results
        final results = <CompressionResult>[
          CompressionResult(
            methodName: 'No Compression',
            originalSize: noShrinkSize,
            compressedSize: noShrinkSize,
            correct: true,
          ),
          CompressionResult(
            methodName: 'zlib',
            originalSize: noShrinkSize,
            compressedSize: shrunken.length,
            correct: true,
          ),
        ];

        allResults[dataset] = results;
      }

      // Log all results in a table
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

    test('shrinkBytes and restoreBytes with very large data', () {
      var logger = LogsGroup.empty();

      // Generate a large byte array (1MB)
      final largeBytes = randomBytes(1024 * 1024);

      final stopwatch = Stopwatch()..start();
      final shrunken = shrinkBytes(largeBytes);
      final compressionTime = stopwatch.elapsedMilliseconds;

      stopwatch.reset();
      stopwatch.start();
      final restored = restoreBytes(shrunken);
      final decompressionTime = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      // Create dataset info for logging
      final dataset = DatasetInfo(
        'Large Random Data (1MB)',
        largeBytes.toList(), // Convert to List<int>
        'Testing compression performance with large data',
      );

      // Calculate no compression baseline size
      final noShrinkSize = largeBytes.length;
      final compressionRatio = noShrinkSize / shrunken.length;

      // Create compression results
      final results = <CompressionResult>[
        CompressionResult(
          methodName: 'zlib',
          originalSize: noShrinkSize,
          compressedSize: shrunken.length,
          correct: true,
        ),
      ];

      // Log the compression results
      var logs = CompressionLogger.logCompressionResults(
        dataset: dataset,
        results: results,
      );

      logger.addLogs(logs);

      // Print the performance metadata separately
      logger.addLogs([
        'Performance: Compression time: ${compressionTime}ms | Decompression time: ${decompressionTime}ms | Ratio: ${compressionRatio.toStringAsFixed(2)}x'
      ]);

      // Print all logs at the end of the test case
      if (enableLogging) {
        logger.printAll();
      }

      expect(restored, equals(largeBytes));
    });
  });
}

import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:shrink/utils/bytes.dart';
import 'package:archive/archive.dart';

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
      final sequentialBytes =
          Uint8List.fromList(List.generate(100, (i) => i % 256));

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
      final repetitiveBytes = Uint8List.fromList(
          List.generate(1000, (i) => i % 10) // Only 10 unique values repeating
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
        _BytesTestInfo('Sequential',
            Uint8List.fromList(List.generate(1000, (i) => i % 256))),
        _BytesTestInfo('Repetitive',
            Uint8List.fromList(List.generate(1000, (i) => i % 10))),
        _BytesTestInfo('Random', randomBytes(1000)),
        _BytesTestInfo(
            'Alternating',
            Uint8List.fromList(
                List.generate(1000, (i) => i % 2 == 0 ? 0 : 255))),
        _BytesTestInfo(
            'Mostly-Zeros',
            Uint8List.fromList(
                List.generate(1000, (i) => i < 950 ? 0 : i % 256))),
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
        expect(restored, equals(testData.data),
            reason:
                'Failed to restore bytes of length ${testData.data.length}');

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

    // New tests for compression method verification

    test('Verify correct method byte assignment', () {
      // Create test data that will be compressible
      final testData = Uint8List.fromList(List.generate(1000, (i) => i % 10));

      // Compress the data
      final compressed = shrinkBytes(testData);

      // The first byte should be the method byte
      final methodByte = compressed[0];

      // Check that the method byte is in one of the valid ranges:
      // 0 (identity), 19-27 (zlib), or 28-36 (gzip)
      expect(methodByte == 0 || (methodByte >= 19 && methodByte <= 36), isTrue,
          reason: 'Method byte ($methodByte) outside valid ranges');

      // For repetitive data, the method byte should not be 0 (identity)
      // as compression should be effective
      expect(methodByte, isNot(0),
          reason: 'Repetitive data should be compressed');
    });

    test('Test each compression method explicitly', () {
      var logger = LogsGroup.empty();

      // Create compressible data
      final testData = Uint8List.fromList(List.generate(2000, (i) => i % 20));

      // Create mock entries for legacy compression methods (1-9)
      final results = <String, CompressionTestResult>{};

      // Helper function to manually compress with a specific method
      Uint8List manualCompress(Uint8List data, int methodByte,
          List<int> Function(List<int>) compressor) {
        final compressed = compressor(data);
        final result = Uint8List(compressed.length + 1);
        result[0] = methodByte;
        result.setRange(1, result.length, compressed);
        return result;
      }

      // Test all compression methods
      final zLibEncoder = ZLibEncoder();
      final gZipEncoder = GZipEncoder();

      // Test ZLIB compression (levels 1-9)
      for (int level = 1; level <= 9; level++) {
        final methodByte = 19 + (level - 1); // ZLIB method bytes: 19-27

        final compressed = manualCompress(testData, methodByte,
            (data) => zLibEncoder.encode(data, level: level));

        final restored = restoreBytes(compressed);

        final isCorrect = listEquals(restored, testData);
        final compressionRatio = testData.length / compressed.length;

        results['ZLIB (level $level)'] = CompressionTestResult(
          methodByte: methodByte,
          compressedSize: compressed.length,
          originalSize: testData.length,
          compressionRatio: compressionRatio,
          isCorrect: isCorrect,
        );
      }

      // Test GZIP compression (levels 1-9)
      for (int level = 1; level <= 9; level++) {
        final methodByte = 28 + (level - 1); // GZIP method bytes: 28-36

        final compressed = manualCompress(testData, methodByte,
            (data) => gZipEncoder.encode(data, level: level));

        final restored = restoreBytes(compressed);

        final isCorrect = listEquals(restored, testData);
        final compressionRatio = testData.length / compressed.length;

        results['GZIP (level $level)'] = CompressionTestResult(
          methodByte: methodByte,
          compressedSize: compressed.length,
          originalSize: testData.length,
          compressionRatio: compressionRatio,
          isCorrect: isCorrect,
        );
      }

      // Log the results
      logger.addLogs(['Compression Method Test Results:']);
      logger.addLogs([
        '| Method | Method Byte | Original Size | Compressed Size | Ratio | Correct |'
      ]);
      logger.addLogs([
        '|--------|-------------|---------------|-----------------|-------|---------|'
      ]);

      results.forEach((method, result) {
        logger.addLogs([
          '| $method | ${result.methodByte} | ${result.originalSize} | ${result.compressedSize} | ${result.compressionRatio.toStringAsFixed(2)}x | ${result.isCorrect ? '✓' : '✗'} |'
        ]);

        // Also verify with expect
        expect(result.isCorrect, isTrue,
            reason: 'Compression method $method failed');
      });

      if (enableLogging) {
        logger.printAll();
      }
    });

    test('Legacy compression method support', () {
      var logger = LogsGroup.empty();

      // Create test data
      final testData = Uint8List.fromList(List.generate(1000, (i) => i % 50));

      // Create mock legacy compressed data (method bytes 1-9)
      final results = <String, bool>{};

      // Helper function to manually compress with a specific legacy method
      Uint8List createLegacyCompressed(Uint8List data, int legacyMethodByte,
          List<int> Function(List<int>) compressor) {
        final compressed = compressor(data);
        final result = Uint8List(compressed.length + 1);
        result[0] = legacyMethodByte;
        result.setRange(1, result.length, compressed);
        return result;
      }

      final zLibEncoder = ZLibEncoder();
      final gZipEncoder = GZipEncoder();

      // Test legacy method bytes (1-9) with ZLIB data
      for (int legacyMethod = 1; legacyMethod <= 9; legacyMethod++) {
        final compressed = createLegacyCompressed(testData, legacyMethod,
            (data) => zLibEncoder.encode(data, level: legacyMethod));

        try {
          final restored = restoreBytes(compressed);
          final isCorrect = listEquals(restored, testData);
          results['Legacy ZLIB (method=$legacyMethod)'] = isCorrect;

          expect(isCorrect, isTrue,
              reason:
                  'Failed to restore legacy ZLIB data with method byte $legacyMethod');
        } catch (e) {
          results['Legacy ZLIB (method=$legacyMethod)'] = false;
          fail(
              'Failed to restore legacy ZLIB data with method byte $legacyMethod: $e');
        }
      }

      // Test legacy method bytes (1-9) with GZIP data
      for (int legacyMethod = 1; legacyMethod <= 9; legacyMethod++) {
        final compressed = createLegacyCompressed(testData, legacyMethod,
            (data) => gZipEncoder.encode(data, level: legacyMethod));

        try {
          final restored = restoreBytes(compressed);
          final isCorrect = listEquals(restored, testData);
          results['Legacy GZIP (method=$legacyMethod)'] = isCorrect;

          expect(isCorrect, isTrue,
              reason:
                  'Failed to restore legacy GZIP data with method byte $legacyMethod');
        } catch (e) {
          results['Legacy GZIP (method=$legacyMethod)'] = false;
          fail(
              'Failed to restore legacy GZIP data with method byte $legacyMethod: $e');
        }
      }

      // Log the results
      logger.addLogs(['Legacy Compression Method Support Test Results:']);
      logger.addLogs(['| Method | Restored Correctly |']);
      logger.addLogs(['|--------|---------------------|']);

      results.forEach((method, isCorrect) {
        logger.addLogs(['| $method | ${isCorrect ? '✓' : '✗'} |']);
      });

      if (enableLogging) {
        logger.printAll();
      }
    });

    test('Real-world scenarios with different data types', () {
      var logger = LogsGroup.empty();

      // Test different types of real-world data
      final realWorldData = <_BytesTestInfo>[
        // JSON data (structured, somewhat compressible)
        _BytesTestInfo(
            'JSON Data',
            Uint8List.fromList(
                '{"name":"Example","items":[1,2,3,4,5],"nested":{"a":1,"b":2,"c":3},"descriptions":["Lorem ipsum dolor sit amet","consectetur adipiscing elit"]}'
                    .codeUnits)),

        // HTML content (highly compressible with repeated tags)
        _BytesTestInfo(
            'HTML Content',
            Uint8List.fromList(
                '''<!DOCTYPE html><html><head><title>Test Page</title></head><body>
          <div class="container">
            <h1>Hello World</h1>
            <p>This is a test paragraph with some content.</p>
            <ul>
              <li>Item 1</li>
              <li>Item 2</li>
              <li>Item 3</li>
            </ul>
          </div>
          </body></html>'''
                    .codeUnits)),

        // Base64 encoded data (hard to compress)
        _BytesTestInfo(
            'Base64 Data',
            Uint8List.fromList(
                'dGhpcyBpcyBhIHRlc3Qgc3RyaW5nIGZvciBiYXNlNjQgZW5jb2RpbmcgdGVzdGluZyBjb21wcmVzc2lvbiBhbGdvcml0aG1z'
                    .codeUnits)),

        // Binary data with patterns (somewhat compressible)
        _BytesTestInfo(
            'Binary Patterns',
            Uint8List.fromList(List.generate(
                1000, (i) => (i ~/ 50) % 2 == 0 ? i % 256 : 255 - (i % 256)))),

        // Text with high repetition (highly compressible)
        _BytesTestInfo(
            'Repetitive Text',
            Uint8List.fromList(List.generate(
                    50, (i) => 'The quick brown fox jumps over the lazy dog. ')
                .join()
                .codeUnits)),
      ];

      final datasets = <DatasetInfo>[];
      final allResults = <DatasetInfo, CompressionTestResult>{};

      for (final testData in realWorldData) {
        final dataset = DatasetInfo(
          testData.name,
          testData.data.toList(),
          'Testing compression with ${testData.name}',
        );
        datasets.add(dataset);

        final shrunken = shrinkBytes(testData.data);
        final methodByte = shrunken[0];
        final restored = restoreBytes(shrunken);

        // Verify restoration works correctly
        expect(listEquals(restored, testData.data), isTrue,
            reason:
                'Failed to restore ${testData.name} of length ${testData.data.length}');

        final compressionRatio = testData.data.length / shrunken.length;

        String methodName;
        if (methodByte == 0) {
          methodName = 'Identity';
        } else if (methodByte >= 19 && methodByte <= 27) {
          methodName = 'ZLIB (level ${methodByte - 18})';
        } else if (methodByte >= 28 && methodByte <= 36) {
          methodName = 'GZIP (level ${methodByte - 27})';
        } else {
          methodName = 'Unknown';
        }

        allResults[dataset] = CompressionTestResult(
          methodByte: methodByte,
          methodName: methodName,
          originalSize: testData.data.length,
          compressedSize: shrunken.length,
          compressionRatio: compressionRatio,
          isCorrect: true,
        );
      }

      // Log all results in a table
      logger.addLogs(['Real-world Data Compression Results:']);
      logger.addLogs([
        '| Data Type | Method | Method Byte | Original Size | Compressed Size | Ratio |'
      ]);
      logger.addLogs([
        '|-----------|--------|-------------|---------------|-----------------|-------|'
      ]);

      for (var dataset in datasets) {
        final result = allResults[dataset]!;
        logger.addLogs([
          '| ${dataset.name} | ${result.methodName} | ${result.methodByte} | ${result.originalSize} | ${result.compressedSize} | ${result.compressionRatio.toStringAsFixed(2)}x |'
        ]);
      }

      if (enableLogging) {
        logger.printAll();
      }
    });
  });
}

/// Helper method to compare lists
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Helper class to track compression test results
class CompressionTestResult {
  final int methodByte;
  final String? methodName;
  final int originalSize;
  final int compressedSize;
  final double compressionRatio;
  final bool isCorrect;

  CompressionTestResult({
    required this.methodByte,
    this.methodName,
    required this.originalSize,
    required this.compressedSize,
    required this.compressionRatio,
    required this.isCorrect,
  });
}

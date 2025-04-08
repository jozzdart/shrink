import 'dart:convert';
import 'package:test/test.dart';
import 'package:shrink/utils/json.dart';

import '../generators/generators.dart';
import '../logs/logs.dart';

// Set to false to disable logging in tests
const bool enableLogging = true;

void main() {
  group('JSON Utils Tests', () {
    test('shrinkJson and restoreJson work with empty object', () {
      final emptyJson = <String, dynamic>{};

      final shrunken = shrinkJson(emptyJson);
      final restored = restoreJson(shrunken);

      expect(restored, equals(emptyJson));
    });

    test('shrinkJson and restoreJson work with simple object', () {
      final simpleJson = {
        'name': 'Test User',
        'age': 30,
        'active': true,
      };

      final shrunken = shrinkJson(simpleJson);
      final restored = restoreJson(shrunken);

      expect(restored, equals(simpleJson));
    });

    test('shrinkJson and restoreJson work with nested objects', () {
      final nestedJson = {
        'user': {
          'name': 'Test User',
          'address': {
            'street': '123 Main St',
            'city': 'Anytown',
            'zip': '12345',
          },
        },
        'preferences': {
          'notifications': true,
          'theme': 'dark',
        },
      };

      final shrunken = shrinkJson(nestedJson);
      final restored = restoreJson(shrunken);

      expect(restored, equals(nestedJson));
    });

    test('shrinkJson and restoreJson work with arrays', () {
      final jsonWithArrays = {
        'tags': ['one', 'two', 'three'],
        'scores': [95, 87, 92, 78],
        'mixed': [
          'string',
          123,
          true,
          {'key': 'value'}
        ],
      };

      final shrunken = shrinkJson(jsonWithArrays);
      final restored = restoreJson(shrunken);

      expect(restored, equals(jsonWithArrays));
    });

    test('shrinkJson and restoreJson handle special characters', () {
      final jsonWithSpecialChars = {
        'unicodeText': '你好，世界！',
        'emoji': '🚀🌟🎮🎯📱🏆',
        'symbols': '§±¶×÷€£¥©®™',
        'escapeChars': 'Line 1\nLine 2\tTabbed\r\nWindows',
        'quotesAndSlashes': '"Quoted" text with \\ backslashes',
      };

      final shrunken = shrinkJson(jsonWithSpecialChars);
      final restored = restoreJson(shrunken);

      expect(restored, equals(jsonWithSpecialChars));
    });

    test('shrinkJson compresses data', () {
      // Generate a large JSON object to ensure compression happens
      final largeJson = randomJson(50, maxDepth: 3);

      final shrunken = shrinkJson(largeJson);
      final jsonString = jsonEncode(largeJson);

      // Verify that the compressed data is smaller than the JSON string
      expect(shrunken.length, lessThan(jsonString.length));
    });

    test('shrinkJson and restoreJson with multiple random JSON data', () {
      var logger = LogsGroup.empty();
      final testDataSet = generateJsonTestData();

      final datasets = <DatasetInfo>[];
      final allResults = <DatasetInfo, List<CompressionResult>>{};

      for (final testData in testDataSet) {
        final jsonString = jsonEncode(testData);
        final shrunken = shrinkJson(testData);
        final restored = restoreJson(shrunken);

        // Create dataset info
        final dataset = DatasetInfo(
          'JSON ${datasets.length + 1}',
          [], // Cannot store the actual JSON object here, so using empty list
          'JSON object with ${jsonString.length} characters',
        );
        datasets.add(dataset);

        // Calculate compression metrics
        final originalSize = jsonString.length;

        // Create compression result
        final results = <CompressionResult>[
          CompressionResult(
            methodName: 'JSON Compression',
            originalSize: originalSize,
            compressedSize: shrunken.length,
            correct: mapEquals(restored, testData),
          ),
        ];

        allResults[dataset] = results;

        expect(restored, equals(testData), reason: 'Failed to restore JSON object');
      }

      // Log the results
      var table = CompressionLogger.logMultipleDatasetResults(
        datasets: datasets,
        allResults: allResults,
      );

      logger.addLogs(table);

      if (enableLogging) {
        logger.printAll();
      }
    });

    test('JSON compression performance with various data types', () {
      var logger = LogsGroup.empty();

      // Test with different types of JSON data
      final jsonTypes = [
        {
          'name': 'Simple Flat',
          'data': {'id': 1, 'name': 'Test', 'value': 123.45, 'active': true}
        },
        {
          'name': 'Deeply Nested',
          'data': {
            'level1': {
              'level2': {
                'level3': {
                  'level4': {
                    'level5': {'data': 'Deeply nested value'}
                  }
                }
              }
            }
          }
        },
        {
          'name': 'Large Array',
          'data': {'items': List.generate(1000, (i) => 'Item $i')}
        },
        {
          'name': 'Repeated Structure',
          'data': {
            'users': List.generate(
                100,
                (i) => {
                      'id': i,
                      'name': 'User $i',
                      'roles': ['user', 'member'],
                      'preferences': {'theme': 'light', 'notifications': true}
                    })
          }
        },
        {
          'name': 'Mixed Content',
          'data': {
            'metadata': {'version': '1.0', 'generated': DateTime.now().toIso8601String()},
            'counts': {'users': 1000, 'items': 5000, 'transactions': 25000},
            'flags': {'isTest': true, 'debug': false, 'maintenance': false},
            'sampleData': List.generate(50, (i) => {'key': 'value$i', 'count': i})
          }
        },
      ];

      final datasets = <DatasetInfo>[];
      final allResults = <DatasetInfo, List<CompressionResult>>{};

      for (final jsonType in jsonTypes) {
        final name = jsonType['name'] as String;
        final data = jsonType['data'] as Map<String, dynamic>;

        final jsonString = jsonEncode(data);

        // Measure compression time
        final stopwatch = Stopwatch()..start();
        final shrunken = shrinkJson(data);
        final compressionTime = stopwatch.elapsedMilliseconds;

        // Measure decompression time
        stopwatch.reset();
        stopwatch.start();
        final restored = restoreJson(shrunken);
        final decompressionTime = stopwatch.elapsedMilliseconds;
        stopwatch.stop();

        // Create dataset info (using empty list since we can't store the actual JSON)
        final dataset = DatasetInfo(
          name,
          [],
          'JSON with ${jsonString.length} characters',
        );
        datasets.add(dataset);

        // Calculate original size and compression ratio
        final originalSize = jsonString.length;
        final compressionRatio = originalSize / shrunken.length;

        // Create results
        final results = <CompressionResult>[
          CompressionResult(
            methodName: 'JSON Compression',
            originalSize: originalSize,
            compressedSize: shrunken.length,
            correct: mapEquals(restored, data),
          ),
        ];

        allResults[dataset] = results;

        // Add performance information
        logger.addLogs([
          'Performance ($name): Compression: ${compressionTime}ms | Decompression: ${decompressionTime}ms | Ratio: ${compressionRatio.toStringAsFixed(2)}x'
        ]);

        // Verify restoration works
        expect(restored, equals(data));
      }

      // Log all results
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

/// Helper function to compare maps
bool mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (a.isEmpty) return b.isEmpty;

  return a.entries.every((entry) {
    final bValue = b[entry.key];

    if (bValue == null && !b.containsKey(entry.key)) return false;

    if (entry.value is Map && bValue is Map) {
      return mapEquals(entry.value as Map, bValue as Map);
    } else if (entry.value is List && bValue is List) {
      if ((entry.value as List).length != (bValue as List).length) return false;

      for (var i = 0; i < (entry.value as List).length; i++) {
        final aItem = (entry.value as List)[i];
        final bItem = (bValue as List)[i];

        if (aItem is Map && bItem is Map) {
          if (!mapEquals(aItem, bItem)) return false;
        } else if (aItem is List && bItem is List) {
          // Handle nested lists
          if (!_listEquals(aItem, bItem)) return false;
        } else if (aItem is num && bItem is num) {
          // Handle numeric comparisons with potential type differences
          if ((aItem - bItem).abs() > 1e-10) return false;
        } else if (aItem.runtimeType != bItem.runtimeType) {
          // If types don't match but both are JSON serializable primitive types,
          // convert to string for comparison (handles int/double conversion issues)
          if ((aItem is num || aItem is String || aItem is bool) && (bItem is num || bItem is String || bItem is bool)) {
            if (aItem.toString() != bItem.toString()) return false;
          } else {
            return false;
          }
        } else if (aItem != bItem) {
          return false;
        }
      }

      return true;
    }

    // Handle numeric comparisons with potential type differences
    if (entry.value is num && bValue is num) {
      return ((entry.value as num) - (bValue as num)).abs() < 1e-10;
    }

    return entry.value == bValue;
  });
}

/// Helper function to compare lists
bool _listEquals(List a, List b) {
  if (a.length != b.length) return false;

  for (var i = 0; i < a.length; i++) {
    final aItem = a[i];
    final bItem = b[i];

    if (aItem is Map && bItem is Map) {
      if (!mapEquals(aItem, bItem)) return false;
    } else if (aItem is List && bItem is List) {
      if (!_listEquals(aItem, bItem)) return false;
    } else if (aItem is num && bItem is num) {
      if ((aItem - bItem).abs() > 1e-10) return false;
    } else if (aItem.runtimeType != bItem.runtimeType) {
      // Handle type differences in JSON serializable primitive types
      if ((aItem is num || aItem is String || aItem is bool) && (bItem is num || bItem is String || bItem is bool)) {
        if (aItem.toString() != bItem.toString()) return false;
      } else {
        return false;
      }
    } else if (aItem != bItem) {
      return false;
    }
  }

  return true;
}

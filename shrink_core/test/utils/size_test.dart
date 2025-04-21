import 'dart:convert';
import 'package:test/test.dart';
import 'package:shrink/utils/size.dart';

import '../generators/generators.dart';

void main() {
  group('Size Utils Tests', () {
    test('getStringSize returns correct byte size for ASCII strings', () {
      final testCases = {
        '': 0,
        'a': 1,
        'hello': 5,
        'hello world': 11,
      };

      for (final entry in testCases.entries) {
        final size = getStringSize(entry.key);
        expect(size, equals(entry.value),
            reason: 'Size mismatch for "${entry.key}"');
      }
    });

    test(
        'getStringSize returns correct byte size for UTF-8 multi-byte characters',
        () {
      final testCases = {
        '你': utf8.encode('你').length, // Chinese character (3 bytes in UTF-8)
        '你好': utf8
            .encode('你好')
            .length, // Two Chinese characters (6 bytes in UTF-8)
        '🚀': utf8.encode('🚀').length, // Emoji (4 bytes in UTF-8)
        'αβγ': utf8
            .encode('αβγ')
            .length, // Greek characters (2 bytes each in UTF-8)
      };

      for (final entry in testCases.entries) {
        final size = getStringSize(entry.key);
        expect(size, equals(entry.value),
            reason: 'Size mismatch for "${entry.key}"');
      }
    });

    test('getStringSize works with mixed character types', () {
      // Create strings with mixed ASCII and Unicode
      final mixedStrings = [
        'Hello 你好',
        'Hello 🚀 World',
        'abc123 αβγ 你好 🚀',
      ];

      for (final str in mixedStrings) {
        final expectedSize = utf8.encode(str).length;
        final actualSize = getStringSize(str);
        expect(actualSize, equals(expectedSize),
            reason: 'Size mismatch for "$str"');
      }
    });

    test('getStringSize with random test data', () {
      final testDataSet = generateTextTestData();

      for (final testData in testDataSet) {
        final expectedSize = utf8.encode(testData).length;
        final actualSize = getStringSize(testData);

        expect(actualSize, equals(expectedSize),
            reason: 'Size mismatch for string of length ${testData.length}');
      }
    });
  });
}

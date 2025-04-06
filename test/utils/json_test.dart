import 'dart:convert';
import 'package:test/test.dart';
import 'package:shrink/utils/json.dart';

import 'test_data_generator.dart';

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
      final largeJson = TestDataGenerator.randomJson(50, maxDepth: 3);

      final shrunken = shrinkJson(largeJson);
      final jsonString = jsonEncode(largeJson);

      // Verify that the compressed data is smaller than the JSON string
      expect(shrunken.length, lessThan(jsonString.length));
    });

    test('shrinkJson and restoreJson with multiple random JSON data', () {
      final testDataSet = TestDataGenerator.generateJsonTestData();

      for (final testData in testDataSet) {
        final shrunken = shrinkJson(testData);
        final restored = restoreJson(shrunken);

        expect(restored, equals(testData), reason: 'Failed to restore JSON object');
      }
    });
  });
}

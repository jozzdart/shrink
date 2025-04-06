import 'package:test/test.dart';
import 'package:shrink/utils/text.dart';

import 'test_data_generator.dart';

void main() {
  group('Text Utils Tests', () {
    test('shrinkText and restoreText function correctly for ASCII inputs', () {
      final asciiTests = [
        '', // Empty string
        'a', // Single character
        'hello world', // Simple ASCII
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', // Medium length
        TestDataGenerator.randomString(1000), // Long ASCII string
      ];

      for (final testData in asciiTests) {
        final shrunken = shrinkText(testData);
        final restored = restoreText(shrunken);

        expect(restored, equals(testData), reason: 'Failed to restore text: "$testData"');

        // For non-empty strings, verify compression is happening
        if (testData.isNotEmpty && testData.length > 100) {
          expect(shrunken.length, lessThan(testData.length * 1.5),
              reason: 'Compression ineffective for: "${testData.substring(0, testData.length > 20 ? 20 : testData.length)}..."');
        }
      }
    });

    test('shrinkText handles empty string', () {
      final shrunken = shrinkText('');
      final restored = restoreText(shrunken);

      expect(restored, equals(''));
    });

    test('shrinkText and restoreText work with simple Unicode characters', () {
      final simpleUnicodeStrings = [
        'Hello, 世界!', // Mixed ASCII and simple Unicode
        'αβγδεζηθικλμνξοπρστυφχψω', // Greek alphabet
        '你好，世界！', // Chinese
        '안녕하세요', // Korean
        'こんにちは世界', // Japanese
      ];

      for (final testData in simpleUnicodeStrings) {
        final shrunken = shrinkText(testData);
        final restored = restoreText(shrunken);

        expect(restored, equals(testData), reason: 'Failed to restore simple Unicode text: "$testData"');
      }
    });

    test('shrinkText and restoreText work with emoji', () {
      final emojiStrings = [
        '🚀', // Single emoji
        '🚀🌟🎮🎯📱🏆', // Multiple emoji
        'Hello 🚀 World', // Mixed with ASCII
      ];

      for (final testData in emojiStrings) {
        final shrunken = shrinkText(testData);
        final restored = restoreText(shrunken);

        expect(restored, equals(testData), reason: 'Failed to restore emoji text: "$testData"');
      }
    });

    test('shrinkText and restoreText with long text', () {
      final longText = TestDataGenerator.randomString(10000);

      final shrunken = shrinkText(longText);
      final restored = restoreText(shrunken);

      expect(restored, equals(longText));
      expect(shrunken.length, lessThan(longText.length));
    });
  });
}

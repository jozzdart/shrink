import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

/// Utility class to generate test data for utils tests
class TestDataGenerator {
  static final _random = Random();

  /// Generate a random string of specified length
  static String randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }

  /// Generate a UTF-8 string with a variety of characters
  /// Now uses a more controlled approach to avoid encoding issues
  static String randomUtf8String(int length) {
    // Instead of mixing character sets randomly, we'll use a single character set
    // This helps avoid encoding issues that can occur with certain combinations
    final charSetOptions = [
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', // ASCII
      'áéíóúñçÁÉÍÓÚÑÇ', // Latin characters
      '你好世界', // Chinese
      'こんにちは', // Japanese
      '안녕하세요', // Korean
      '😀🚀🌟📱', // Common emoji
    ];

    // Choose a single character set for this string
    final charSetIndex = _random.nextInt(charSetOptions.length);
    final charSet = charSetOptions[charSetIndex];

    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      final charIndex = _random.nextInt(charSet.length);
      buffer.write(charSet[charIndex]);
    }

    return buffer.toString();
  }

  /// Generate a random JSON object with the specified number of keys
  static Map<String, dynamic> randomJson(int keyCount, {int maxDepth = 2, int currentDepth = 0}) {
    final result = <String, dynamic>{};

    for (int i = 0; i < keyCount; i++) {
      final key = 'key_${randomString(5)}';
      final valueType = _random.nextInt(5);

      switch (valueType) {
        case 0: // String
          result[key] = randomString(10 + _random.nextInt(20));
          break;
        case 1: // Number
          result[key] = _random.nextDouble() * 1000;
          break;
        case 2: // Boolean
          result[key] = _random.nextBool();
          break;
        case 3: // List
          if (currentDepth < maxDepth) {
            result[key] = List.generate(3 + _random.nextInt(5), (_) => _randomJsonValue(maxDepth, currentDepth + 1));
          } else {
            result[key] = _random.nextInt(100);
          }
          break;
        case 4: // Nested object
          if (currentDepth < maxDepth) {
            result[key] = randomJson(3 + _random.nextInt(5), maxDepth: maxDepth, currentDepth: currentDepth + 1);
          } else {
            result[key] = randomString(10);
          }
          break;
      }
    }

    return result;
  }

  /// Generate a random JSON value
  static dynamic _randomJsonValue(int maxDepth, int currentDepth) {
    final valueType = _random.nextInt(5);

    switch (valueType) {
      case 0: // String
        return randomString(5 + _random.nextInt(10));
      case 1: // Number
        return _random.nextDouble() * 100;
      case 2: // Boolean
        return _random.nextBool();
      case 3: // List
        if (currentDepth < maxDepth) {
          return List.generate(2 + _random.nextInt(3), (_) => _randomJsonValue(maxDepth, currentDepth + 1));
        } else {
          return _random.nextInt(100);
        }
      case 4: // Nested object
        if (currentDepth < maxDepth) {
          return randomJson(2 + _random.nextInt(3), maxDepth: maxDepth, currentDepth: currentDepth + 1);
        } else {
          return randomString(5);
        }
      default:
        return null;
    }
  }

  /// Generate random Uint8List of specified size
  static Uint8List randomBytes(int size) {
    final bytes = Uint8List(size);
    for (int i = 0; i < size; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  /// Generate test data sets of different sizes
  static List<String> generateTextTestData() {
    return [
      '', // Empty string
      'a', // Single character
      'hello world', // Simple ASCII
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', // Medium length
      randomString(1000), // Long ASCII string
      // Use controlled Unicode strings rather than randomly mixed ones
      'こんにちは世界', // Japanese
      '你好，世界！', // Chinese
      'αβγδεζηθικλμνξοπρστυφχψω', // Greek
      '안녕하세요', // Korean
      '🚀🌟🎮🎯📱', // Emoji-only
    ];
  }

  /// Generate JSON test data sets of different complexities
  static List<Map<String, dynamic>> generateJsonTestData() {
    return [
      {}, // Empty
      {'key': 'value'}, // Simple
      {
        'nested': {'key': 'value'}
      }, // Nested
      {'array': List.generate(10, (i) => i)}, // With array
      randomJson(5), // Small random
      randomJson(20), // Medium random
      randomJson(50, maxDepth: 3), // Large random with deeper nesting
    ];
  }

  /// Generate bytes test data of different sizes
  static List<Uint8List> generateBytesTestData() {
    return [
      Uint8List(0), // Empty
      Uint8List.fromList([1, 2, 3]), // Small
      randomBytes(100), // Medium
      randomBytes(1000), // Large
      Uint8List.fromList(utf8.encode(randomString(5000))), // Very large
    ];
  }
}

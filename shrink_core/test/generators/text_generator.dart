part of 'generators.dart';

/// Generate a random string of specified length
String randomString(int length) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
}

/// Generate a UTF-8 string with a variety of characters
/// Now uses a more controlled approach to avoid encoding issues
String randomUtf8String(int length) {
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
  final charSetIndex = random.nextInt(charSetOptions.length);
  final charSet = charSetOptions[charSetIndex];

  final buffer = StringBuffer();
  for (int i = 0; i < length; i++) {
    final charIndex = random.nextInt(charSet.length);
    buffer.write(charSet[charIndex]);
  }

  return buffer.toString();
}

/// Generate test data sets of different sizes
List<String> generateTextTestData() {
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

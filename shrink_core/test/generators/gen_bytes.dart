part of 'generators.dart';

/// Generate bytes test data of different sizes
List<Uint8List> generateBytesTestData() {
  return [
    Uint8List(0), // Empty
    Uint8List.fromList([1, 2, 3]), // Small
    randomBytes(100), // Medium
    randomBytes(1000), // Large
    Uint8List.fromList(utf8.encode(randomString(5000))), // Very large
  ];
}

/// Generate random Uint8List of specified size
Uint8List randomBytes(int size) {
  final bytes = Uint8List(size);
  for (int i = 0; i < size; i++) {
    bytes[i] = random.nextInt(256);
  }
  return bytes;
}

import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:shrink/utils/bytes.dart';

import 'test_data_generator.dart';

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
      final randomBytes = TestDataGenerator.randomBytes(500);

      final shrunken = shrinkBytes(randomBytes);
      final restored = restoreBytes(shrunken);

      expect(restored, equals(randomBytes));
    });

    test('shrinkBytes compresses repetitive data efficiently', () {
      // Create highly compressible data (repetitive)
      final repetitiveBytes = Uint8List.fromList(List.generate(1000, (i) => i % 10) // Only 10 unique values repeating
          );

      final shrunken = shrinkBytes(repetitiveBytes);

      // Verify significant compression for repetitive data
      expect(shrunken.length, lessThan(repetitiveBytes.length / 2));
    });

    test('shrinkBytes gives minimal compression for random data', () {
      // Create random data (hardly compressible)
      final randomBytes = TestDataGenerator.randomBytes(1000);

      final shrunken = shrinkBytes(randomBytes);

      // For truly random data, compression might not be very effective
      // But with zlib overhead, it shouldn't be much larger than the original
      expect(shrunken.length, lessThanOrEqualTo(randomBytes.length * 1.1));
    });

    test('shrinkBytes and restoreBytes with multiple random test data', () {
      final testDataSet = TestDataGenerator.generateBytesTestData();

      for (final testData in testDataSet) {
        final shrunken = shrinkBytes(testData);
        final restored = restoreBytes(shrunken);

        expect(restored, equals(testData), reason: 'Failed to restore bytes of length ${testData.length}');
      }
    });

    test('shrinkBytes and restoreBytes with very large data', () {
      // Generate a large byte array (1MB)
      final largeBytes = TestDataGenerator.randomBytes(1024 * 1024);

      final shrunken = shrinkBytes(largeBytes);
      final restored = restoreBytes(shrunken);

      expect(restored, equals(largeBytes));
    });
  });
}

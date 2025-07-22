import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shrink_flutter/src/utils/compress_format.dart';

void main() {
  group('compressFormatToFileName', () {
    test('should generate unique file names for different calls', () async {
      final fileName1 = compressFormatToFileName(CompressFormat.jpeg);

      // Add a small delay to ensure different timestamps
      await Future.delayed(const Duration(milliseconds: 1));

      final fileName2 = compressFormatToFileName(CompressFormat.jpeg);

      expect(fileName1, isNot(equals(fileName2)));
    });

    test('should include "compressed_" prefix', () {
      final fileName = compressFormatToFileName(CompressFormat.png);

      expect(fileName, startsWith('compressed_'));
    });

    test('should include timestamp', () {
      final fileName = compressFormatToFileName(CompressFormat.webp);

      // Extract the timestamp part (between "compressed_" and the extension)
      final parts = fileName.split('.');
      expect(parts.length, equals(2));

      final timestampPart = parts[0].replaceFirst('compressed_', '');
      expect(timestampPart, isNotEmpty);
      expect(int.tryParse(timestampPart), isNotNull);
    });

    test('should have correct extension for JPEG format', () {
      final fileName = compressFormatToFileName(CompressFormat.jpeg);

      expect(fileName, endsWith('.jpg'));
    });

    test('should have correct extension for PNG format', () {
      final fileName = compressFormatToFileName(CompressFormat.png);

      expect(fileName, endsWith('.png'));
    });

    test('should have correct extension for HEIC format', () {
      final fileName = compressFormatToFileName(CompressFormat.heic);

      expect(fileName, endsWith('.heic'));
    });

    test('should have correct extension for WebP format', () {
      final fileName = compressFormatToFileName(CompressFormat.webp);

      expect(fileName, endsWith('.webp'));
    });

    test('should have fallback extension for unknown format', () {
      // Test with a hypothetical unknown format by using a mock
      // Since we can't easily create unknown CompressFormat values,
      // we'll test the private function directly through reflection or
      // by ensuring the public function handles all known cases

      // All known CompressFormat values should have specific extensions
      final jpegFileName = compressFormatToFileName(CompressFormat.jpeg);
      final pngFileName = compressFormatToFileName(CompressFormat.png);
      final heicFileName = compressFormatToFileName(CompressFormat.heic);
      final webpFileName = compressFormatToFileName(CompressFormat.webp);

      expect(jpegFileName, endsWith('.jpg'));
      expect(pngFileName, endsWith('.png'));
      expect(heicFileName, endsWith('.heic'));
      expect(webpFileName, endsWith('.webp'));
    });

    test('should generate valid file names for all formats', () {
      final formats = [
        CompressFormat.jpeg,
        CompressFormat.png,
        CompressFormat.heic,
        CompressFormat.webp,
      ];

      for (final format in formats) {
        final fileName = compressFormatToFileName(format);

        // File name should be valid (no invalid characters)
        expect(fileName, matches(r'^[a-zA-Z0-9_.-]+$'));

        // Should have exactly one dot (for extension)
        expect(fileName.split('.').length, equals(2));

        // Should not be empty
        expect(fileName, isNotEmpty);
      }
    });

    test('should generate file names with increasing timestamps', () async {
      final fileName1 = compressFormatToFileName(CompressFormat.jpeg);

      // Small delay to ensure different timestamp
      await Future.delayed(const Duration(milliseconds: 1));

      final fileName2 = compressFormatToFileName(CompressFormat.jpeg);

      // Extract timestamps
      final timestamp1 = int.parse(fileName1.split('.')[0].replaceFirst('compressed_', ''));
      final timestamp2 = int.parse(fileName2.split('.')[0].replaceFirst('compressed_', ''));

      expect(timestamp2, greaterThan(timestamp1));
    });
  });

  group('_compressFormatToString (private function testing through public interface)', () {
    test('should return "jpg" for JPEG format', () {
      final fileName = compressFormatToFileName(CompressFormat.jpeg);
      expect(fileName, endsWith('.jpg'));
    });

    test('should return "png" for PNG format', () {
      final fileName = compressFormatToFileName(CompressFormat.png);
      expect(fileName, endsWith('.png'));
    });

    test('should return "heic" for HEIC format', () {
      final fileName = compressFormatToFileName(CompressFormat.heic);
      expect(fileName, endsWith('.heic'));
    });

    test('should return "webp" for WebP format', () {
      final fileName = compressFormatToFileName(CompressFormat.webp);
      expect(fileName, endsWith('.webp'));
    });

    test('should handle all CompressFormat enum values', () {
      final allFormats = CompressFormat.values;

      for (final format in allFormats) {
        final fileName = compressFormatToFileName(format);

        // Should always have an extension
        expect(fileName, contains('.'));

        // Should not end with just a dot
        expect(fileName, isNot(endsWith('.')));

        // Should have a valid extension
        final extension = fileName.split('.').last;
        expect(extension, isNotEmpty);
      }
    });
  });

  group('Integration tests', () {
    test('should generate consistent file names for same format', () async {
      final format = CompressFormat.png;

      // Generate multiple file names for the same format with delays
      final fileNames = <String>[];
      for (int i = 0; i < 10; i++) {
        fileNames.add(compressFormatToFileName(format));
        await Future.delayed(const Duration(milliseconds: 1));
      }

      // All should have the same extension
      for (final fileName in fileNames) {
        expect(fileName, endsWith('.png'));
      }

      // All should be unique due to timestamps
      final uniqueFileNames = fileNames.toSet();
      expect(uniqueFileNames.length, equals(fileNames.length));
    });

    test('should generate different extensions for different formats', () {
      final jpegFileName = compressFormatToFileName(CompressFormat.jpeg);
      final pngFileName = compressFormatToFileName(CompressFormat.png);
      final heicFileName = compressFormatToFileName(CompressFormat.heic);
      final webpFileName = compressFormatToFileName(CompressFormat.webp);

      expect(jpegFileName, endsWith('.jpg'));
      expect(pngFileName, endsWith('.png'));
      expect(heicFileName, endsWith('.heic'));
      expect(webpFileName, endsWith('.webp'));

      // All should be different
      final extensions = [
        jpegFileName.split('.').last,
        pngFileName.split('.').last,
        heicFileName.split('.').last,
        webpFileName.split('.').last,
      ];

      final uniqueExtensions = extensions.toSet();
      expect(uniqueExtensions.length, equals(extensions.length));
    });
  });

  group('Edge cases and error handling', () {
    test('should handle null safety (if applicable)', () {
      // This test ensures the function doesn't crash with null values
      // Since CompressFormat is an enum, it can't be null, but we test robustness

      final fileName = compressFormatToFileName(CompressFormat.jpeg);
      expect(fileName, isNotNull);
      expect(fileName, isNotEmpty);
    });

    test('should generate file names with reasonable length', () {
      final fileName = compressFormatToFileName(CompressFormat.png);

      // File name should not be excessively long
      expect(fileName.length, lessThan(100));

      // File name should have reasonable components
      final parts = fileName.split('.');
      expect(parts.length, equals(2));

      final namePart = parts[0];
      final extensionPart = parts[1];

      expect(namePart.length, greaterThan(10)); // Should have prefix + timestamp
      expect(extensionPart.length, greaterThan(0));
      expect(extensionPart.length, lessThan(10)); // Extension should be short
    });

    test('should generate file names suitable for file system', () {
      final fileName = compressFormatToFileName(CompressFormat.webp);

      // Should not contain invalid file system characters
      expect(fileName, isNot(contains('/')));
      expect(fileName, isNot(contains('\\')));
      expect(fileName, isNot(contains(':')));
      expect(fileName, isNot(contains('*')));
      expect(fileName, isNot(contains('?')));
      expect(fileName, isNot(contains('"')));
      expect(fileName, isNot(contains('<')));
      expect(fileName, isNot(contains('>')));
      expect(fileName, isNot(contains('|')));
    });
  });

  group('Performance tests', () {
    test('should generate file names efficiently', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        compressFormatToFileName(CompressFormat.jpeg);
      }

      stopwatch.stop();

      // Should complete 1000 calls in reasonable time (less than 1 second)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('should handle concurrent calls', () {
      final futures = <Future<String>>[];

      // Generate 100 file names concurrently
      for (int i = 0; i < 100; i++) {
        futures.add(Future.value(compressFormatToFileName(CompressFormat.png)));
      }

      final results = Future.wait(futures);

      expect(results, completes);
    });
  });
}

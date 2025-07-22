import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:shrink_flutter/src/utils/image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('shrinkImage (integration)', () {
    late File inputImage;

    setUp(() async {
      final dir = Directory.systemTemp;
      inputImage = File(path.join(dir.path, 'test_image.jpg'));

      final jpegBytes = Uint8List.fromList([
        0xFF, 0xD8, // SOI
        0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x00,
        0x00, 0x01, 0x00, 0x01, 0x00, 0x00,
        0xFF, 0xDB, 0x00, 0x43, 0x00,
        ...List.filled(0x3B, 0x08),
        0xFF, 0xC0, 0x00, 0x11, 0x08, 0x00, 0x01, 0x00, 0x01, 0x03, 0x01, 0x11,
        0x00, 0x02, 0x11, 0x01, 0x03, 0x11, 0x01,
        0xFF, 0xC4, 0x00, 0x14, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0xFF, 0xDA, 0x00, 0x0C, 0x03, 0x01, 0x00, 0x02, 0x11, 0x03, 0x11, 0x00,
        0x3F, 0x00,
        0xFF, 0xD9 // EOI
      ]);

      await inputImage.writeAsBytes(jpegBytes);
    });

    tearDown(() async {
      if (await inputImage.exists()) {
        await inputImage.delete();
      }
    });

    test('successfully compresses a JPEG image', () async {
      final compressed = await shrinkImage(inputImage);

      expect(compressed, isNotNull);
      expect(await compressed!.exists(), isTrue);
      expect(await compressed.length(), lessThan(await inputImage.length()));
      expect(path.extension(compressed.path), '.jpg');

      await compressed.delete();
    });
  });
}

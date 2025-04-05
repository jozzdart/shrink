import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:shrink/core/shrink_utils.dart';

void main() {
  group('ShrinkUtils compression tests', () {
    test('Test compression and size reduction with text data', () {
      // Original test data
      final String originalText = 'This is a test string that will be compressed and measured. '
          'Adding some repetition to improve compression: '
          'test test test test test test test test test test '
          'compression compression compression compression compression '
          'data data data data data data data data data data data.';

      final Uint8List originalData = Uint8List.fromList(originalText.codeUnits);
      final int originalLength = originalData.length;

      print('Original text data size: $originalLength bytes');

      // Test compression to binary
      final Uint8List compressed = ShrinkUtils.compressBytes(originalData);
      final int compressedLength = compressed.length;

      print('Compressed binary size: $compressedLength bytes');
      print('Binary compression ratio: ${(compressedLength / originalLength * 100).toStringAsFixed(2)}% of original');
      print('Binary space saved: ${originalLength - compressedLength} bytes (${((1 - compressedLength / originalLength) * 100).toStringAsFixed(2)}%)');

      // Test prefixed and compressed
      final Uint8List prefixed = ShrinkUtils.addLengthPrefix(originalData, originalLength);
      final Uint8List prefixedCompressed = ShrinkUtils.compressBytes(prefixed);

      print('Prefixed and compressed binary size: ${prefixedCompressed.length} bytes');

      // Test conversion to string (base64)
      final String base64String = ShrinkUtils.encodeWithLengthPrefix(originalData, originalLength);
      final int stringLength = base64String.length;

      print('Base64 encoded string size: $stringLength bytes/chars');
      print('String encoding ratio: ${(stringLength / originalLength * 100).toStringAsFixed(2)}% of original');

      // Verify round-trip
      final ShrunkPayload decoded = ShrinkUtils.decodeWithLengthPrefix(base64String);
      expect(decoded.length, equals(originalLength));
      expect(decoded.data, equals(originalData));

      print('Successfully verified round-trip encoding and decoding.');
    });

    test('Test compression with binary data', () {
      // Create some binary data with patterns
      final Uint8List binaryData = Uint8List(1000);
      for (int i = 0; i < binaryData.length; i++) {
        binaryData[i] = (i % 256); // Repeating pattern helps compression
      }

      final int originalSize = binaryData.length;
      print('\nOriginal binary data size: $originalSize bytes');

      // Compress to binary
      final Uint8List compressed = ShrinkUtils.compressBytes(binaryData);
      final int compressedSize = compressed.length;

      print('Compressed binary size: $compressedSize bytes');
      print('Binary compression ratio: ${(compressedSize / originalSize * 100).toStringAsFixed(2)}% of original');
      print('Binary space saved: ${originalSize - compressedSize} bytes (${((1 - compressedSize / originalSize) * 100).toStringAsFixed(2)}%)');

      // Encode to string
      final String base64String = ShrinkUtils.encodeWithLengthPrefix(binaryData, originalSize);
      final int stringSize = base64String.length;

      print('Base64 encoded string size: $stringSize bytes/chars');
      print('String encoding ratio: ${(stringSize / originalSize * 100).toStringAsFixed(2)}% of original');

      // Verify round-trip
      final ShrunkPayload decoded = ShrinkUtils.decodeWithLengthPrefix(base64String);
      expect(decoded.length, equals(originalSize));
      expect(decoded.data, equals(binaryData));

      print('Successfully verified round-trip encoding and decoding for binary data.');
    });

    test('Test with large repetitive data for maximum compression', () {
      // Create data with high redundancy to demonstrate good compression
      final StringBuffer buffer = StringBuffer();
      for (int i = 0; i < 1000; i++) {
        buffer.write('repetitive text block ');
      }
      final String repetitiveText = buffer.toString();
      final Uint8List originalData = Uint8List.fromList(repetitiveText.codeUnits);

      final int originalSize = originalData.length;
      print('\nLarge repetitive data size: $originalSize bytes');

      // Compress to binary
      final Uint8List compressed = ShrinkUtils.compressBytes(originalData);
      final int compressedSize = compressed.length;

      print('Compressed binary size: $compressedSize bytes');
      print('Binary compression ratio: ${(compressedSize / originalSize * 100).toStringAsFixed(2)}% of original');
      print('Binary space saved: ${originalSize - compressedSize} bytes (${((1 - compressedSize / originalSize) * 100).toStringAsFixed(2)}%)');

      // Encode to string with the full pipeline
      final String base64String = ShrinkUtils.encodeWithLengthPrefix(originalData, originalSize);
      final int stringSize = base64String.length;

      print('Base64 encoded string size: $stringSize bytes/chars');
      print('String encoding ratio: ${(stringSize / originalSize * 100).toStringAsFixed(2)}% of original');

      // Verify data integrity with round-trip
      final ShrunkPayload decoded = ShrinkUtils.decodeWithLengthPrefix(base64String);
      expect(decoded.length, equals(originalSize));
      expect(decoded.data, equals(originalData));

      print('Successfully verified round-trip encoding and decoding for large repetitive data.');
    });
  });
}

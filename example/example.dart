import 'dart:convert';
import 'dart:typed_data';

import 'package:shrink/shrink.dart';

void main() {
  // Create some sample data
  final String originalString = 'Hello, Shrink Extension!';
  final Uint8List originalBytes = utf8.encode(originalString);

  print('Original string: $originalString');
  print('Original bytes length: ${originalBytes.length}');

  // Using Uint8List extensions
  print('\n--- Uint8List extensions ---');

  // Simple shrink (compress + base64)
  final String shrunk = originalBytes.shrink();
  print('Shrunk data: $shrunk');

  // Shrink with length prefix
  final String shrunkWithLength = originalBytes.shrinkWithLength();
  print('Shrunk with length: $shrunkWithLength');

  // Individual operations
  final Uint8List compressed = originalBytes.compress();
  print('Compressed bytes length: ${compressed.length}');

  final String base64Encoded = originalBytes.toBase64();
  print('Base64 encoded: $base64Encoded');

  // Using String extensions
  print('\n--- String extensions ---');

  // Unshrink without length
  final Uint8List unshrunkBytes = shrunk.unshrink();
  final String unshrunkString = utf8.decode(unshrunkBytes);
  print('Unshrunk string: $unshrunkString');

  // Unshrink with length
  final ShrunkPayload payload = shrunkWithLength.unshrinkWithLength();
  print('Payload length: ${payload.length}');
  print('Payload data as string: ${utf8.decode(payload.data)}');

  // Integer set example
  print('\n--- Integer set example ---');
  final List<int> ids = [1, 5, 10, 42, 100];
  print('Original IDs: $ids');

  // Using extension method
  final String encodedIdsWithExtension = ids.shrinkUniqueSet();
  print('Encoded IDs (using extension): $encodedIdsWithExtension');

  // Decode using extension
  final List<int> decodedIds = encodedIdsWithExtension.unshrinkIntegerSet();
  print('Decoded IDs: $decodedIds');
}

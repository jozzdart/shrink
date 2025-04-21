import 'dart:io'; // Added for ZLibEncoder
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shrink/core/core.dart';
import 'package:shrink_flutter/shrink_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Required for compute

  group('RestoreAsync', () {
    group('bytes', () {
      test('should decompress bytes compressed with identity', () async {
        final original = Uint8List.fromList([1, 2, 3, 4, 5]);
        // Manually create identity "compressed" data (byte 0 indicates identity)
        final compressed = Uint8List.fromList([0, ...original]);
        final decompressed = Restore.bytes(compressed);
        expect(decompressed, equals(original));
      });

      test('should decompress bytes compressed with zlib', () async {
        final original = Uint8List.fromList(List.generate(100, (i) => i % 256));
        final compressed = Shrink.bytes(
          original,
        ); // Use sync Shrink to compress
        // Ensure it actually compressed (first byte > 0)
        expect(compressed[0], greaterThan(0));

        final decompressed = await RestoreAsync.bytes(compressed);
        expect(decompressed, equals(original));
      });

      test(
        'should handle empty input (throws ArgumentError eventually)',
        () async {
          // compute wraps the error in a Future that completes with an error
          expectLater(RestoreAsync.bytes(Uint8List(0)), throwsArgumentError);
        },
      );

      test(
        'should handle invalid compression method (throws UnsupportedError eventually)',
        () async {
          final invalidCompressed = Uint8List.fromList([
            99,
            1,
            2,
            3,
          ]); // Assume 99 is invalid
          expectLater(
            RestoreAsync.bytes(invalidCompressed),
            throwsUnsupportedError,
          );
        },
      );

      test(
        'should handle corrupted zlib data (throws FormatException eventually)',
        () async {
          final original = Uint8List.fromList(List.generate(50, (i) => i));
          var compressed = Shrink.bytes(original);
          // Ensure it's zlib compressed
          if (compressed[0] == 0) {
            // Force zlib compression if identity was chosen
            compressed = shrinkBytes(original, forceZlib: true);
          }
          expect(compressed[0], greaterThan(0)); // Check it's not identity

          // Corrupt the data (e.g., truncate)
          final corruptedData = Uint8List.sublistView(
            compressed,
            0,
            compressed.length - 5,
          );

          expectLater(RestoreAsync.bytes(corruptedData), throwsFormatException);
        },
      );
    });

    group('json', () {
      test('should decompress simple JSON', () async {
        final originalJson = {'message': 'hello', 'value': 123};
        final compressed = Shrink.json(originalJson);
        final decompressedJson = await RestoreAsync.json(compressed);
        expect(decompressedJson, equals(originalJson));
      });

      test('should decompress complex JSON', () async {
        final originalJson = {
          'user': 'test',
          'active': true,
          'roles': ['admin', 'editor'],
          'prefs': {'theme': 'dark', 'notifications': null},
          'history': [
            {'action': 'login', 'timestamp': 1678886400},
            {'action': 'edit', 'timestamp': 1678886460},
          ],
          'values': [1, 2.5, -3, 1e5],
        };
        final compressed = Shrink.json(originalJson);
        final decompressedJson = await RestoreAsync.json(compressed);
        expect(decompressedJson, equals(originalJson));
      });

      test('should decompress JSON with various data types', () async {
        final originalJson = {
          'string': 'string value',
          'int': 42,
          'double': 3.14159,
          'bool_true': true,
          'bool_false': false,
          'null_value': null,
          'list_mixed': [1, 'two', true, null, 3.0],
          'map_nested': {'nested_key': 'nested_value'},
        };
        final compressed = Shrink.json(originalJson);
        final decompressedJson = await RestoreAsync.json(compressed);
        expect(decompressedJson, equals(originalJson));
      });

      test('should handle empty map', () async {
        final originalJson = <String, dynamic>{};
        final compressed = Shrink.json(originalJson);
        final decompressedJson = await RestoreAsync.json(compressed);
        expect(decompressedJson, equals(originalJson));
      });

      test(
        'should handle corrupted JSON data (throws FormatException eventually)',
        () async {
          final originalJson = {'a': 1};
          final compressed = Shrink.json(originalJson);
          // Corrupt the data
          final corruptedData = Uint8List.sublistView(
            compressed,
            0,
            compressed.length - 1,
          );

          // Decoding error happens during JSON parsing after decompression
          expectLater(RestoreAsync.json(corruptedData), throwsFormatException);
        },
      );
    });

    group('text', () {
      test('should decompress simple text', () async {
        const originalText = 'Hello, world!';
        final compressed = Shrink.text(originalText);
        final decompressedText = await RestoreAsync.text(compressed);
        expect(decompressedText, equals(originalText));
      });

      test('should decompress longer text', () async {
        final originalText =
            'This is a longer piece of text designed to test compression effectiveness. ' *
            10;
        final compressed = Shrink.text(originalText);
        final decompressedText = await RestoreAsync.text(compressed);
        expect(decompressedText, equals(originalText));
      });

      test('should decompress text with special characters', () async {
        const originalText = 'Testing UTF-8: ñéîøü € Grüß Gott! 🚀';
        final compressed = Shrink.text(originalText);
        final decompressedText = await RestoreAsync.text(compressed);
        expect(decompressedText, equals(originalText));
      });

      test('should handle empty string', () async {
        const originalText = '';
        final compressed = Shrink.text(originalText);
        final decompressedText = await RestoreAsync.text(compressed);
        expect(decompressedText, equals(originalText));
      });

      test(
        'should handle corrupted text data (throws FormatException eventually)',
        () async {
          const originalText = 'Some text data';
          final compressed = Shrink.text(originalText);
          // Corrupt the data
          final corruptedData = Uint8List.sublistView(
            compressed,
            0,
            compressed.length - 2,
          );

          // Zlib decompression or UTF-8 decoding might fail
          expectLater(RestoreAsync.text(corruptedData), throwsFormatException);
        },
      );
    });

    group('unique', () {
      test('should decompress unique list (delta)', () async {
        final originalList = List.generate(100, (i) => i * 2);
        final compressed = Shrink.unique(originalList);
        final decompressedList = await RestoreAsync.unique(compressed);
        expect(decompressedList, equals(originalList));
      });

      test('should decompress unique list (rle)', () async {
        final originalList = [1, 2, 3, 10, 11, 12, 13, 20, 21, 22];
        final compressed = Shrink.unique(
          originalList,
        ); // Might choose RLE or Delta
        final decompressedList = await RestoreAsync.unique(compressed);
        expect(decompressedList, equals(originalList));
      });

      test('should decompress unique list (chunked)', () async {
        final originalList = List.generate(50, (i) => i * 1000);
        final compressed = Shrink.unique(originalList); // Likely Chunked
        final decompressedList = await RestoreAsync.unique(compressed);
        expect(decompressedList, equals(originalList));
      });

      test('should decompress unique list (bitmask)', () async {
        final originalList = [
          1,
          5,
          10,
          15,
          20,
          30,
          63,
        ]; // Small range, might use bitmask
        final compressed = Shrink.unique(originalList);
        final decompressedList = await RestoreAsync.unique(compressed);
        expect(decompressedList, equals(originalList));
      });

      test('should handle empty list', () async {
        final originalList = <int>[];
        final compressed = Shrink.unique(originalList);
        final decompressedList = await RestoreAsync.unique(compressed);
        expect(decompressedList, equals(originalList));
      });

      test('should handle list with one element', () async {
        final originalList = [42];
        final compressed = Shrink.unique(originalList);
        final decompressedList = await RestoreAsync.unique(compressed);
        expect(decompressedList, equals(originalList));
      });

      test('should handle large numbers', () async {
        final originalList = [1, 1000, 1000000, 2000000000];
        final compressed = Shrink.unique(originalList);
        final decompressedList = await RestoreAsync.unique(compressed);
        expect(decompressedList, equals(originalList));
      });

      test(
        'should handle corrupted unique data (throws Exception eventually)',
        () async {
          final originalList = [1, 5, 10, 20];
          final compressed = Shrink.unique(originalList);
          // Corrupt the data
          final corruptedData = Uint8List.sublistView(
            compressed,
            0,
            compressed.length > 1 ? compressed.length - 1 : 0,
          );

          // The specific exception might vary depending on corruption and method
          expectLater(RestoreAsync.unique(corruptedData), throwsException);
        },
      );
    });
  });
}

// Helper to force zlib for testing bytes decompression
Uint8List shrinkBytes(Uint8List bytes, {bool forceZlib = false}) {
  if (bytes.isEmpty) {
    return Uint8List.fromList([0]); // Represent empty list with identity
  }

  // Try ZLIB compression
  final zlibEncoder = ZLibEncoder(level: 6); // Use a standard level
  final zlibCompressed = Uint8List.fromList(zlibEncoder.convert(bytes));

  if (forceZlib) {
    return Uint8List.fromList([1, ...zlibCompressed]); // Assume 1 is ZLIB
  }

  // Normally, Shrink.bytes would choose the smaller one.
  // Here, we just simulate the zlib path for testing RestoreAsync.
  if (zlibCompressed.length < bytes.length) {
    return Uint8List.fromList([1, ...zlibCompressed]); // Assume 1 is ZLIB
  } else {
    return Uint8List.fromList([0, ...bytes]); // Use identity
  }
}

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shrink/core/restore.dart'; // Use synchronous Restore for verification
import 'package:shrink/utils/utils.dart';
import 'package:shrink_flutter/shrink_flutter.dart'; // For UniqueCompressionMethod

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Required for compute

  group('ShrinkAsync', () {
    group('bytes', () {
      test('should compress bytes and allow decompression', () async {
        final original = Uint8List.fromList(
          List.generate(200, (i) => (i * 3) % 256),
        );
        final compressed = await ShrinkAsync.bytes(original);

        // Verify using synchronous Restore
        final decompressed = Restore.bytes(compressed);
        expect(decompressed, equals(original));
      });

      test('should handle empty bytes (produces identity header)', () async {
        final original = Uint8List(0);
        final compressed = await ShrinkAsync.bytes(original);

        // Empty list compressed with identity is [0]
        expect(compressed, equals(Uint8List.fromList([0])));

        final decompressed = Restore.bytes(compressed);
        expect(decompressed, equals(original));
      });

      test('should handle short bytes (likely identity)', () async {
        final original = Uint8List.fromList([1, 2, 3]);
        final compressed = await ShrinkAsync.bytes(original);

        // Verify using synchronous Restore
        final decompressed = Restore.bytes(compressed);
        expect(decompressed, equals(original));
        // Small lists are often larger when compressed, so identity (0) is used
        if (compressed.length > 1) {
          // Ensure it's not the empty case
          expect(compressed[0], equals(0));
          expect(compressed.sublist(1), equals(original));
        }
      });
    });

    group('json', () {
      test('should compress simple JSON and allow decompression', () async {
        final originalJson = {'message': 'async test', 'count': 42};
        final compressed = await ShrinkAsync.json(originalJson);

        // Verify using synchronous Restore
        final decompressedJson = Restore.json(compressed);
        expect(decompressedJson, equals(originalJson));
      });

      test('should compress complex JSON and allow decompression', () async {
        final originalJson = {
          'id': 'xyz789',
          'enabled': false,
          'tags': ['async', 'flutter', 'test'],
          'config': {'retries': 3, 'timeout': 5.5},
          'items': [
            {'name': 'A', 'value': 100},
            {'name': 'B', 'value': null},
          ],
        };
        final compressed = await ShrinkAsync.json(originalJson);

        // Verify using synchronous Restore
        final decompressedJson = Restore.json(compressed);
        expect(decompressedJson, equals(originalJson));
      });

      test('should handle empty JSON map', () async {
        final originalJson = <String, dynamic>{};
        final compressed = await ShrinkAsync.json(originalJson);

        // Verify using synchronous Restore
        final decompressedJson = Restore.json(compressed);
        expect(decompressedJson, equals(originalJson));
      });
    });

    group('text', () {
      test('should compress simple text and allow decompression', () async {
        const originalText = 'Compressing text asynchronously.';
        final compressed = await ShrinkAsync.text(originalText);

        // Verify using synchronous Restore
        final decompressedText = Restore.text(compressed);
        expect(decompressedText, equals(originalText));
      });

      test(
        'should compress long repetitive text and allow decompression',
        () async {
          final originalText = ('abc' * 100) + ('123' * 100);
          final compressed = await ShrinkAsync.text(originalText);

          // Verify using synchronous Restore
          final decompressedText = Restore.text(compressed);
          expect(decompressedText, equals(originalText));
          // Compression should be effective here
          expect(compressed.length, lessThan(originalText.length));
        },
      );

      test(
        'should compress text with unicode and allow decompression',
        () async {
          const originalText = '你好世界 async 😃👍';
          final compressed = await ShrinkAsync.text(originalText);

          // Verify using synchronous Restore
          final decompressedText = Restore.text(compressed);
          expect(decompressedText, equals(originalText));
        },
      );

      test('should handle empty string', () async {
        const originalText = '';
        final compressed = await ShrinkAsync.text(originalText);

        // Verify using synchronous Restore
        final decompressedText = Restore.text(compressed);
        expect(decompressedText, equals(originalText));
        // Empty string compressed likely results in minimal zlib overhead
      });
    });

    group('unique', () {
      test(
        'should compress unique list (auto) and allow decompression',
        () async {
          final originalList = List.generate(150, (i) => i * 3 + 10);
          final compressed = await ShrinkAsync.unique(originalList);

          // Verify using synchronous Restore
          final decompressedList = Restore.unique(compressed);
          expect(decompressedList, equals(originalList));
        },
      );

      test('should handle empty list (auto)', () async {
        final originalList = <int>[];
        final compressed = await ShrinkAsync.unique(originalList);

        // Verify using synchronous Restore
        final decompressedList = Restore.unique(compressed);
        expect(decompressedList, equals(originalList));
        // Check for expected empty compressed representation (might vary)
        expect(compressed.length, lessThan(5)); // Should be very small
      });

      test('should handle list with one element (auto)', () async {
        final originalList = [12345];
        final compressed = await ShrinkAsync.unique(originalList);

        // Verify using synchronous Restore
        final decompressedList = Restore.unique(compressed);
        expect(decompressedList, equals(originalList));
      });

      test('should handle list with large gaps (auto)', () async {
        final originalList = [10, 1000, 100000, 50000000];
        final compressed = await ShrinkAsync.unique(originalList);

        // Verify using synchronous Restore
        final decompressedList = Restore.unique(compressed);
        expect(decompressedList, equals(originalList));
      });

      test('should handle list suitable for RLE (auto)', () async {
        final originalList = [1, 2, 3, 10, 11, 12, 13, 100, 101, 102];
        final compressed = await ShrinkAsync.unique(originalList);

        // Verify using synchronous Restore
        final decompressedList = Restore.unique(compressed);
        expect(decompressedList, equals(originalList));
      });
    });

    group('uniqueManual', () {
      test('should compress using delta and allow decompression', () async {
        final originalList = List.generate(100, (i) => i * 2);
        final args = UniqueManualArgs(
          originalList,
          UniqueCompressionMethod.deltaVarint,
        );
        final compressed = await ShrinkAsync.uniqueManual(args);

        // Verify using synchronous Restore (which detects method automatically)
        final decompressedList = Restore.unique(compressed);
        expect(decompressedList, equals(originalList));
        // Optionally, check if the header byte indicates Delta (implementation specific)
      });

      test('should compress using rle and allow decompression', () async {
        final originalList = [5, 6, 7, 8, 20, 21, 22, 50, 51];
        final args = UniqueManualArgs(
          originalList,
          UniqueCompressionMethod.runLength,
        );
        final compressed = await ShrinkAsync.uniqueManual(args);

        final decompressedList = Restore.unique(compressed);
        expect(decompressedList, equals(originalList));
      });

      test('should compress using bitmask and allow decompression', () async {
        final originalList = [
          0,
          1,
          5,
          10,
          20,
          31,
        ]; // Suitable for bitmask (small range)
        final args = UniqueManualArgs(
          originalList,
          UniqueCompressionMethod.bitmask,
        );
        final compressed = await ShrinkAsync.uniqueManual(args);

        final decompressedList = Restore.unique(compressed);
        expect(decompressedList, equals(originalList));
      });

      test('should compress using chunked and allow decompression', () async {
        final originalList = [
          100,
          10000,
          1000000,
          999999999,
        ]; // Large gaps, chunked might be good
        final args = UniqueManualArgs(
          originalList,
          UniqueCompressionMethod.chunked,
        );
        final compressed = await ShrinkAsync.uniqueManual(args);

        final decompressedList = Restore.unique(compressed);
        expect(decompressedList, equals(originalList));
      });

      test('should handle empty list (manual)', () async {
        final originalList = <int>[];
        final args = UniqueManualArgs(
          originalList,
          UniqueCompressionMethod.deltaVarint,
        );
        final compressed = await ShrinkAsync.uniqueManual(args);

        final decompressedList = Restore.unique(compressed);
        expect(decompressedList, equals(originalList));
      });
    });
  });
}

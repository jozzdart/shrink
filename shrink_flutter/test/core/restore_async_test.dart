import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shrink/shrink.dart';
import 'package:shrink_flutter/shrink_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Required for compute

  group('RestoreAsync', () {
    group('bytes', () {
      test('should return same result as Restore.bytes for small data', () async {
        final original = Uint8List.fromList([1, 2, 3, 4, 5]);
        final compressed = Shrink.bytes(original);

        final syncResult = Restore.bytes(compressed);
        final asyncResult = await RestoreAsync.bytes(compressed);

        expect(asyncResult, equals(syncResult));
        expect(asyncResult, equals(original));
      });

      test('should return same result as Restore.bytes for larger data', () async {
        final original = Uint8List.fromList(List.generate(1000, (i) => i % 256));
        final compressed = Shrink.bytes(original);

        final syncResult = Restore.bytes(compressed);
        final asyncResult = await RestoreAsync.bytes(compressed);

        expect(asyncResult, equals(syncResult));
        expect(asyncResult, equals(original));
      });

      test('should return same result as Restore.bytes for empty data', () async {
        final original = Uint8List(0);
        final compressed = Shrink.bytes(original);

        final syncResult = Restore.bytes(compressed);
        final asyncResult = await RestoreAsync.bytes(compressed);

        expect(asyncResult, equals(syncResult));
        expect(asyncResult, equals(original));
      });

      test('should handle errors the same way as Restore.bytes', () async {
        final invalidData = Uint8List(0);

        expect(() => Restore.bytes(invalidData), throwsArgumentError);
        expectLater(RestoreAsync.bytes(invalidData), throwsArgumentError);
      });
    });

    group('json', () {
      test('should return same result as Restore.json for simple JSON', () async {
        final originalJson = {'message': 'hello', 'value': 123};
        final compressed = Shrink.json(originalJson);

        final syncResult = Restore.json(compressed);
        final asyncResult = await RestoreAsync.json(compressed);

        expect(asyncResult, equals(syncResult));
        expect(asyncResult, equals(originalJson));
      });

      test('should return same result as Restore.json for complex JSON', () async {
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

        final syncResult = Restore.json(compressed);
        final asyncResult = await RestoreAsync.json(compressed);

        expect(asyncResult, equals(syncResult));
        expect(asyncResult, equals(originalJson));
      });

      test('should return same result as Restore.json for empty map', () async {
        final originalJson = <String, dynamic>{};
        final compressed = Shrink.json(originalJson);

        final syncResult = Restore.json(compressed);
        final asyncResult = await RestoreAsync.json(compressed);

        expect(asyncResult, equals(syncResult));
        expect(asyncResult, equals(originalJson));
      });
    });

    group('text', () {
      test('should return same result as Restore.text for simple text', () async {
        const originalText = 'Hello, world!';
        final compressed = Shrink.text(originalText);

        final syncResult = Restore.text(compressed);
        final asyncResult = await RestoreAsync.text(compressed);

        expect(asyncResult, equals(syncResult));
        expect(asyncResult, equals(originalText));
      });

      test('should return same result as Restore.text for longer text', () async {
        final originalText = 'This is a longer piece of text designed to test compression effectiveness. ' * 10;
        final compressed = Shrink.text(originalText);

        final syncResult = Restore.text(compressed);
        final asyncResult = await RestoreAsync.text(compressed);

        expect(asyncResult, equals(syncResult));
        expect(asyncResult, equals(originalText));
      });

      test('should return same result as Restore.text for special characters', () async {
        const originalText = 'Testing UTF-8: ñéîøü € Grüß Gott! 🚀';
        final compressed = Shrink.text(originalText);

        final syncResult = Restore.text(compressed);
        final asyncResult = await RestoreAsync.text(compressed);

        expect(asyncResult, equals(syncResult));
        expect(asyncResult, equals(originalText));
      });

      test('should return same result as Restore.text for empty string', () async {
        const originalText = '';
        final compressed = Shrink.text(originalText);

        final syncResult = Restore.text(compressed);
        final asyncResult = await RestoreAsync.text(compressed);

        expect(asyncResult, equals(syncResult));
        expect(asyncResult, equals(originalText));
      });
    });

    group('unique', () {
      test('should return same result as Restore.unique for sequential data', () async {
        final originalList = List.generate(100, (i) => i * 2);
        final compressed = Shrink.unique(originalList);

        final syncResult = Restore.unique(compressed);
        final asyncResult = await RestoreAsync.unique(compressed);

        expect(asyncResult, equals(syncResult));
        expect(asyncResult, equals(originalList));
      });

      test('should return same result as Restore.unique for scattered data', () async {
        final originalList = [1, 5, 10, 15, 20, 30, 63];
        final compressed = Shrink.unique(originalList);

        final syncResult = Restore.unique(compressed);
        final asyncResult = await RestoreAsync.unique(compressed);

        expect(asyncResult, equals(syncResult));
        expect(asyncResult, equals(originalList));
      });

      test('should return same result as Restore.unique for empty list', () async {
        final originalList = <int>[];
        final compressed = Shrink.unique(originalList);

        final syncResult = Restore.unique(compressed);
        final asyncResult = await RestoreAsync.unique(compressed);

        expect(asyncResult, equals(syncResult));
        expect(asyncResult, equals(originalList));
      });

      test('should return same result as Restore.unique for single element', () async {
        final originalList = [42];
        final compressed = Shrink.unique(originalList);

        final syncResult = Restore.unique(compressed);
        final asyncResult = await RestoreAsync.unique(compressed);

        expect(asyncResult, equals(syncResult));
        expect(asyncResult, equals(originalList));
      });

      test('should return same result as Restore.unique for large numbers', () async {
        final originalList = [1, 1000, 1000000, 2000000000];
        final compressed = Shrink.unique(originalList);

        final syncResult = Restore.unique(compressed);
        final asyncResult = await RestoreAsync.unique(compressed);

        expect(asyncResult, equals(syncResult));
        expect(asyncResult, equals(originalList));
      });
    });
  });
}

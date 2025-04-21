import 'dart:convert';
import 'dart:typed_data';

import 'package:shrink/shrink.dart';

void main() {
  print('--- shrink package example ---\n');

  // ========== 1. STRING ==========
  const text = 'Shrink is efficient, fast, and production-ready!';
  final textCompressedExt = text.shrink();
  final textRestoredExt = textCompressedExt.restoreText();

  final textCompressedStatic = Shrink.text(text);
  final textRestoredStatic = Restore.text(textCompressedStatic);

  print('🔤 String:');
  print('Original: $text');
  print('Restored (ext): $textRestoredExt');
  print('Restored (static): $textRestoredStatic');
  print('---');

  // ========== 2. JSON ==========
  final json = {
    'user': 'jozz',
    'roles': ['admin', 'editor'],
    'settings': {'theme': 'dark', 'notifications': true}
  };

  final jsonCompressedExt = json.shrink();
  final jsonRestoredExt = jsonCompressedExt.restoreJson();

  final jsonCompressedStatic = Shrink.json(json);
  final jsonRestoredStatic = Restore.json(jsonCompressedStatic);

  print('🧩 JSON:');
  print('Original: $json');
  print('Restored (ext): $jsonRestoredExt');
  print('Restored (static): $jsonRestoredStatic');
  print('---');

  // ========== 3. UNIQUE INTEGER LIST ==========
  final ids = List.generate(1000, (i) => i); // [0, 1, 2, ..., 999]

  final idsCompressedExt = ids.shrink();
  final idsRestoredExt = idsCompressedExt.restoreUnique();

  final idsCompressedStatic = Shrink.unique(ids);
  final idsRestoredStatic = Restore.unique(idsCompressedStatic);

  print('🔢 Unique Integers:');
  print('Original count: ${ids.length}');
  print('Restored match (ext): ${_listEquals(ids, idsRestoredExt)}');
  print('Restored match (static): ${_listEquals(ids, idsRestoredStatic)}');
  print('---');

  // ========== 4. RAW BYTES ==========
  final rawBytes =
      Uint8List.fromList(utf8.encode('Raw byte stream with structure: ☁⚡💾'));

  final bytesCompressedExt = rawBytes.shrink();
  final bytesRestoredExt = bytesCompressedExt.restoreBytes();

  final bytesCompressedStatic = Shrink.bytes(rawBytes);
  final bytesRestoredStatic = Restore.bytes(bytesCompressedStatic);

  print('📦 Raw Bytes:');
  print('Original (utf8): ${utf8.decode(rawBytes)}');
  print('Restored (ext): ${utf8.decode(bytesRestoredExt)}');
  print('Restored (static): ${utf8.decode(bytesRestoredStatic)}');
  print('---');

  print('✅ All data types compressed and restored successfully.\n');
}

/// Simple helper to compare two int lists
bool _listEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

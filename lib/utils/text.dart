import 'dart:convert';
import 'dart:typed_data';

import 'package:shrink/utils/bytes.dart';

Uint8List shrinkText(String text) {
  final bytes = utf8.encode(text);
  return shrinkBytes(bytes);
}

String restoreText(Uint8List shrunken) {
  final restored = restoreBytes(shrunken);
  return utf8.decode(restored);
}

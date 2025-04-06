import 'dart:convert';
import 'dart:typed_data';
import 'package:shrink/utils/shrink_types.dart';

import '../utils/shrink_utils.dart';

/// Extensions on [String] for direct shrinking operations on text.
extension TextShrinkExtensions on String {
  Uint8List compressText() {
    final bytes = utf8.encode(this);
    final compressed = ShrinkCompressor.compressBytes(bytes);
    return compressed;
  }

  String shrinkText() {
    final bytes = utf8.encode(this);
    final shrunk = ShrinkCompressor.shrinkBytes(bytes);
    return shrunk;
  }

  /// Decodes this shrunk string to a UTF-8 string.
  String unshrinkText() {
    final unshrink = ShrinkCompressor.unshrinkBytes(this);
    return utf8.decode(unshrink);
  }

  ShrinkType get shrinkType => ShrinkType.text;
}

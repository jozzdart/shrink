import 'dart:convert';
import 'dart:typed_data';

import 'package:shrink/utils/shrink_types.dart';

import '../utils/shrink_utils.dart';

/// Extensions on [Uint8List] to provide simplified access to Shrink functionality.
extension Uint8ListShrinkExtensions on Uint8List {
  /// Compresses and encodes this byte array to a Base64 string.
  String shrink() {
    return ShrinkCompressor.shrinkBytes(this);
  }

  /// Compresses this byte array using zlib.
  Uint8List compress() {
    return ShrinkCompressor.compressBytes(this);
  }

  String decompressText() {
    return utf8.decode(ShrinkCompressor.decompressBytes(this));
  }

  ShrinkType get shrinkType => ShrinkType.bytes;
}

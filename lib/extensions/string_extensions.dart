import 'dart:typed_data';
import 'dart:collection';
import '../utils/shrink_utils.dart';

/// Extensions on [String] to provide simplified access to Shrink functionality.
extension StringShrinkExtensions on String {
  /// Decodes this Base64 string into a Uint8List and decompresses it.
  Uint8List unshrinkBytes() {
    return ShrinkCompressor.unshrinkBytes(this);
  }

  /// Decodes this Base64 string and decompresses it to recover a list of integers with unique id.
  List<int> unshrinkUnique() {
    return ShrinkCompressor.unshrinkUnique(this);
  }

  /// Decodes this Base64 string and decompresses it to recover a HashSet of integers.
  HashSet<int> unshrinkHashSet() {
    return HashSet<int>.from(ShrinkCompressor.unshrinkUnique(this));
  }

  Set<int> unshrinkUniqueSet() {
    return Set<int>.from(ShrinkCompressor.unshrinkUnique(this));
  }
}

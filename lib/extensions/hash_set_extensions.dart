import 'dart:collection';
import '../utils/shrink_utils.dart';

/// Extensions on [HashSet<int>] to provide simplified access to Shrink functionality.
extension HashSetOfIntShrinkExtensions on HashSet<int> {
  /// Encodes this hash set of integers into a bitmask, compresses it, and encodes to Base64.
  String shrink() {
    return ShrinkCompressor.shrinkUnique(toList());
  }
}

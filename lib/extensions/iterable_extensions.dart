import '../utils/shrink_utils.dart';

/// Extensions on [Iterable<int>] to provide simplified access to Shrink functionality.
/// This works with any collection of integers (List, Set, HashSet, etc.).
extension IterableOfIntShrinkExtensions on Iterable<int> {
  /// Encodes this collection of integers into a bitmask, compresses it, and encodes to Base64.
  String shrink() {
    return ShrinkCompressor.shrinkUnique(toList());
  }
}

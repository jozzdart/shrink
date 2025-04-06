import '../utils/shrink_utils.dart';

/// Extensions on [List<int>] to provide simplified access to Shrink functionality.
extension ListOfIntShrinkExtensions on List<int> {
  /// Encodes this list of integers into a bitmask, compresses it, and encodes to Base64.
  String shrink() {
    return ShrinkCompressor.shrinkUnique(this);
  }
}

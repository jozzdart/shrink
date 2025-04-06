import 'dart:typed_data';

import 'package:shrink/utils/utils.dart' as utils;

/// Extensions on [List<int>] for compressing unique integer lists.
///
/// These extension methods make it more convenient to compress lists of
/// unique integers by allowing method chaining.
extension ShrinkExtensionsListInt on List<int> {
  /// Compresses this list of unique integers using the most efficient algorithm.
  ///
  /// This method automatically tries multiple compression algorithms and selects
  /// the one that produces the smallest result for the given input. It works best
  /// when the list contains unique integers (no duplicates).
  ///
  /// For decompression, use [Uint8List.restoreUnique].
  ///
  /// Returns a [Uint8List] containing the compressed integer list.
  Uint8List shrinkUnique() => utils.shrinkUnique(this);
}

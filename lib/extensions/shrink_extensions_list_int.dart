import 'dart:typed_data';

import 'package:shrink/utils/list/unique.dart';
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
  Uint8List shrink() => utils.shrinkUnique(this);

  /// Compresses this list of unique integers using a specified compression method.
  ///
  /// Important: The automatic [shrink] method is recommended over this manual option
  /// in most cases, as it intelligently selects the optimal compression algorithm,
  /// which can yield significantly better compression ratios for different data patterns.
  ///
  /// Unlike [shrink], which automatically selects the best compression algorithm,
  /// this method lets you manually choose a specific compression method from the
  /// [UniqueCompressionMethod] enum:
  ///
  /// - [UniqueCompressionMethod.deltaVarint]: Good for sorted lists with small gaps
  /// - [UniqueCompressionMethod.runLength]: Good for lists with consecutive runs of integers
  /// - [UniqueCompressionMethod.chunked]: Good for lists with clustered values
  /// - [UniqueCompressionMethod.bitmask]: Good for dense sets of integers within a limited range
  ///
  /// For decompression, use [Uint8List.restoreUnique].
  ///
  /// Parameters:
  ///   [method]: The specific compression method to use
  ///
  /// Returns a [Uint8List] containing the compressed integer list.
  Uint8List shrinkManual(UniqueCompressionMethod method) => utils.shrinkUniqueManual(this, method);
}

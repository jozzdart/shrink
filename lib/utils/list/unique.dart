import 'dart:typed_data';

import 'methods/methods.dart';

/// Enum representing different compression methods for unique integer lists
enum UniqueCompressionMethod {
  /// Uses delta encoding with variable-length integers
  deltaVarint,

  /// Uses run-length encoding for consecutive integers
  runLength,

  /// Splits the list into chunks and encodes each chunk separately
  chunked,

  /// Uses a bitmap representation for dense integer sets
  bitmask,
}

/// Compresses a list of unique integers using the most efficient method.
///
/// This function automatically tries multiple compression algorithms and selects
/// the one that produces the smallest result for the given input:
///
/// - Delta-encoding with variable-length integers (good for sorted lists with small gaps)
/// - Run-length encoding (good for lists with consecutive runs of integers)
/// - Chunked encoding (good for lists with clustered values)
/// - Bitmask encoding (good for dense sets of integers within a limited range)
///
/// The first byte of the returned [Uint8List] indicates the compression method used,
/// followed by the compressed data.
///
/// Returns a compressed [Uint8List] representation of the integer list.
Uint8List shrinkUnique(List<int> ids) {
  // Make a copy and ensure the list is sorted
  final sortedIds = [...ids]..sort();

  // Try each compression method
  final List<Uint8List> compressed = [
    encodeDeltaVarint(sortedIds),
    encodeRuns(sortedIds),
    encodeChunked(sortedIds),
    encodeBitmask(sortedIds),
  ];

  // Find the most efficient compression method
  int bestMethodIndex = 0;
  int bestSize = compressed[0].length;

  for (int i = 1; i < compressed.length; i++) {
    if (compressed[i].length < bestSize) {
      bestSize = compressed[i].length;
      bestMethodIndex = i;
    }
  }

  // Create result with method byte + compressed data
  final result = Uint8List(compressed[bestMethodIndex].length + 1);
  result[0] = bestMethodIndex; // First byte stores the method enum ordinal
  result.setRange(1, result.length, compressed[bestMethodIndex]);

  return result;
}

/// Decompresses a [Uint8List] created by [shrinkUnique] back to a list of integers.
///
/// This function reads the compression method from the first byte and then
/// applies the appropriate decompression algorithm to restore the original list.
///
/// Returns the original list of unique integers.
/// Throws an error if the compressed data is corrupted or uses an unknown method.
List<int> restoreUnique(Uint8List compressed) {
  if (compressed.isEmpty) {
    return [];
  }

  // Extract method byte
  final methodIndex = compressed[0];
  final method = UniqueCompressionMethod.values[methodIndex];

  // Extract compressed data (skip method byte)
  final data = Uint8List.sublistView(compressed, 1);

  // Decompress based on method
  switch (method) {
    case UniqueCompressionMethod.deltaVarint:
      return decodeDeltaVarint(data);
    case UniqueCompressionMethod.runLength:
      return decodeRuns(data);
    case UniqueCompressionMethod.chunked:
      return decodeChunked(data);
    case UniqueCompressionMethod.bitmask:
      return decodeBitmask(data);
  }
}

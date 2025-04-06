import 'dart:typed_data';

import 'methods/methods.dart';

/// Enum representing different compression methods for unique integer lists
enum UniqueCompressionMethod {
  deltaVarint,
  runLength,
  chunked,
  bitmask,
}

/// Compresses a list of unique integers using the most efficient method.
/// Returns a Uint8List where the first byte indicates the compression method used.
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

/// Decompresses a Uint8List created by shrinkUnique back to a list of integers.
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

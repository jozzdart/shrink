import 'dart:io';
import 'dart:typed_data';

/// Compresses a [Uint8List] using zlib compression algorithm.
///
/// This is the core compression function used by many of the other utility methods.
/// It uses the standard zlib algorithm which offers a good balance between
/// compression ratio and performance.
///
/// Returns a new [Uint8List] containing the compressed data.
Uint8List shrinkBytes(Uint8List bytes) {
  return Uint8List.fromList(zlib.encode(bytes));
}

/// Decompresses a [Uint8List] that was compressed with zlib.
///
/// This function reverses the compression performed by [shrinkBytes].
///
/// Returns a new [Uint8List] containing the original, uncompressed data.
/// Throws a [FormatException] if the input data is not valid zlib-compressed data.
Uint8List restoreBytes(Uint8List bytes) {
  return Uint8List.fromList(zlib.decode(bytes));
}

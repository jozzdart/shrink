import 'dart:io';
import 'dart:typed_data';

/// Compresses a Uint8List using zlib.
Uint8List shrinkBytes(Uint8List bytes) {
  return Uint8List.fromList(zlib.encode(bytes));
}

/// Decompresses zlib-compressed data.
Uint8List restoreBytes(Uint8List bytes) {
  return Uint8List.fromList(zlib.decode(bytes));
}

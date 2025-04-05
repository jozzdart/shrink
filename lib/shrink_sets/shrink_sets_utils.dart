import 'dart:io';
import 'dart:typed_data';

import 'package:more/collection.dart';

Uint8List compressHybridIdList(List<int> ids) {
  if (ids.isEmpty) return Uint8List(0);

  final sorted = ids.toSet().toList()..sort();
  final writer = BytesBuilder();

  int i = 0;
  while (i < sorted.length) {
    int j = i;

    // Expand window until gap is too large or inefficiency appears
    while (j + 1 < sorted.length && sorted[j + 1] - sorted[j] <= 512) {
      j++;
    }

    final segmentIds = sorted.sublist(i, j + 1);
    final span = segmentIds.last - segmentIds.first + 1;
    final count = segmentIds.length;

    final bitmapCost = (span / 8).ceil(); // bytes
    final listCost = count * 2; // Uint16 per ID

    final useBitmap = (bitmapCost + 7 < listCost); // 7 bytes = header overhead

    if (useBitmap) {
      // Header: [0x01][startId][bitLength]
      writer.addByte(0x01);
      writer.add(_uint32(segmentIds.first));
      writer.add(_uint16(span));

      final bits = BitList(span);
      for (var id in segmentIds) {
        bits[id - segmentIds.first] = true;
      }
      writer.add(toBytes(bits));
    } else {
      // Header: [0x02][startId][idCount]
      writer.addByte(0x02);
      writer.add(_uint32(segmentIds.first));
      writer.add(_uint16(count));

      for (var id in segmentIds) {
        writer.add(_uint16(id));
      }
    }

    i = j + 1;
  }

  return Uint8List.fromList(zlib.encode(writer.toBytes()));
}

Uint8List _uint32(int value) {
  final b = ByteData(4);
  b.setUint32(0, value, Endian.big);
  return b.buffer.asUint8List();
}

Uint8List _uint16(int value) {
  final b = ByteData(2);
  b.setUint16(0, value, Endian.big);
  return b.buffer.asUint8List();
}

List<int> decompressHybridIdList(Uint8List compressed) {
  if (compressed.isEmpty) return [];

  final decompressed = Uint8List.fromList(zlib.decode(compressed));
  final result = <int>[];

  int offset = 0;

  while (offset < decompressed.length) {
    final segmentType = decompressed[offset++];
    final startId = ByteData.sublistView(decompressed, offset, offset + 4).getUint32(0, Endian.big);
    offset += 4;

    final lengthOrCount = ByteData.sublistView(decompressed, offset, offset + 2).getUint16(0, Endian.big);
    offset += 2;

    if (segmentType == 0x01) {
      // Bitmap
      final bitLength = lengthOrCount;
      final byteLength = (bitLength / 8).ceil();
      final bitData = decompressed.sublist(offset, offset + byteLength);
      offset += byteLength;

      final bits = _readBitList(bitData, bitLength);
      for (int i = 0; i < bits.length; i++) {
        if (bits[i]) {
          result.add(startId + i);
        }
      }
    } else if (segmentType == 0x02) {
      // Raw list
      final count = lengthOrCount;
      for (int i = 0; i < count; i++) {
        final id = ByteData.sublistView(decompressed, offset, offset + 2).getUint16(0, Endian.big);
        offset += 2;
        result.add(id);
      }
    } else {
      throw FormatException('Unknown segment type: $segmentType');
    }
  }

  return result;
}

BitList _readBitList(Uint8List bytes, int bitLength) {
  final bits = BitList(bitLength);
  for (int i = 0; i < bitLength; i++) {
    final byte = bytes[i >> 3];
    final mask = 1 << (7 - (i % 8));
    bits[i] = (byte & mask) != 0;
  }
  return bits;
}

Uint8List toBytes(BitList bits) {
  final length = (bits.length / 8).ceil();
  final bytes = Uint8List(length);
  for (int i = 0; i < bits.length; i++) {
    if (bits[i]) {
      bytes[i >> 3] |= 1 << (7 - (i % 8));
    }
  }
  return bytes;
}

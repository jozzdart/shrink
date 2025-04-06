import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:shrink/utils/list/methods/runlength.dart';
import 'package:shrink/utils/list/methods/variant.dart';

void main() {
  group('Run-Length Debug Tests', () {
    test('Verify how runlength encoding works with basic input', () {
      // Create a very simple test case
      final basicList = [1, 5, 10, 15, 20];

      // Sort and debug format of the list
      final sortedList = [...basicList]..sort();
      print('Original sorted list: $sortedList');

      // Debug the encoding process
      final BytesBuilder buffer = BytesBuilder();
      int last = -1;

      print('Encoding process:');
      for (int i = 0; i < sortedList.length;) {
        final int skip = sortedList[i] - (last + 1);
        print('  Value: ${sortedList[i]}, last: $last, skip: $skip');
        writeVarint(buffer, skip);

        int runLength = 1;
        last = sortedList[i];

        while (i + runLength < sortedList.length && sortedList[i + runLength] == sortedList[i + runLength - 1] + 1) {
          print('  Found consecutive: ${sortedList[i + runLength]}');
          last = sortedList[i + runLength];
          runLength++;
        }

        print('  Run length: $runLength');
        writeVarint(buffer, runLength);
        i += runLength;
      }

      final encoded = buffer.toBytes();
      print('Encoded bytes: ${encoded.map((b) => b.toRadixString(16)).join(', ')}');

      // Debug the decoding process
      print('Decoding process:');
      final decoded = <int>[];
      int offset = 0;
      int current = -1;

      while (offset < encoded.length) {
        final skipResult = readVarint(encoded, offset);
        offset = skipResult.offset;
        final skip = skipResult.value;
        print('  Read skip: $skip, new current: ${current + skip + 1}');
        current += skip + 1;

        final runResult = readVarint(encoded, offset);
        offset = runResult.offset;
        final run = runResult.value;
        print('  Read run: $run');

        for (int i = 0; i < run; i++) {
          print('  Adding value: ${current + i}');
          decoded.add(current + i);
        }

        current += run - 1;
      }

      print('Decoded: $decoded');

      // Now test the actual functions
      final encodedActual = encodeRuns(basicList);
      final decodedActual = decodeRuns(encodedActual);

      print('Encoded actual: ${encodedActual.map((b) => b.toRadixString(16)).join(', ')}');
      print('Decoded actual: $decodedActual');

      // Compare and confirm the issue
      expect(encodedActual, equals(encoded));
      expect(decodedActual.toSet(), equals(basicList.toSet()));
    });
  });
}

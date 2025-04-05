import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:shrink/core/shrink_utils.dart';

/// Simple test object with only an ID field
class TestObject {
  final int id;

  TestObject(this.id);

  Map<String, dynamic> toJson() => {'id': id};

  @override
  bool operator ==(Object other) => identical(this, other) || other is TestObject && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Inventory class that holds a collection of test objects
class InventoryTest {
  final List<TestObject> items;

  InventoryTest(this.items);

  Map<String, dynamic> toJson() => {
        'items': items.map((item) => item.toJson()).toList(),
      };

  factory InventoryTest.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List).map((item) => TestObject(item['id'] as int)).toList();
    return InventoryTest(itemsList);
  }
}

/// Formats a number with commas for better readability
String formatNumber(int number) {
  return number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}

void main() {
  group('Inventory data compression tests', () {
    test('Test compression with large inventory data', () {
      // Generate 40 unique random IDs between 1-100000
      final random = Random();
      final Set<int> uniqueIds = {};

      while (uniqueIds.length < 40) {
        uniqueIds.add(random.nextInt(100000) + 1);
      }

      // Create inventory with 40 unique items
      final inventory = InventoryTest(uniqueIds.map((id) => TestObject(id)).toList());

      // Convert to JSON and then to bytes
      final jsonString = jsonEncode(inventory.toJson());

      print('\n========== TEST INVENTORY DATA ==========');
      print('Number of inventory items: ${inventory.items.length}');
      print('Range of IDs: 1 to 100,000 (random, unique)');

      // Truncate JSON string if too long for display
      final displayJson = jsonString.length > 100 ? '${jsonString.substring(0, 100)}... (truncated)' : jsonString;
      print('JSON sample: $displayJson');
      print('JSON string length: ${formatNumber(jsonString.length)} characters');

      final Uint8List jsonBytes = Uint8List.fromList(utf8.encode(jsonString));
      final int originalSize = jsonBytes.length;

      print('\n========== ORIGINAL DATA METRICS ==========');
      print('Original data size: ${formatNumber(originalSize)} bytes');

      // Compress to binary
      final Uint8List compressed = ShrinkUtils.compressBytes(jsonBytes);
      final int compressedSize = compressed.length;
      final double compressionRatio = compressedSize / originalSize * 100;
      final int bytesSaved = originalSize - compressedSize;
      final double percentSaved = (1 - compressedSize / originalSize) * 100;

      print('\n========== BINARY COMPRESSION RESULTS ==========');
      print('Compressed binary size: ${formatNumber(compressedSize)} bytes');
      print('Space saved: ${formatNumber(bytesSaved)} bytes (${percentSaved.toStringAsFixed(2)}%)');
      print('Compression ratio: ${compressionRatio.toStringAsFixed(2)}% of original size');

      // Full encode to string (base64 with length prefix)
      final String base64String = ShrinkUtils.encodeWithLengthPrefix(jsonBytes, originalSize);
      final int stringSize = base64String.length;
      final double stringRatio = stringSize / originalSize * 100;

      print('\n========== BASE64 STRING ENCODING RESULTS ==========');
      print('Base64 encoded size: ${formatNumber(stringSize)} characters');
      print('String encoding ratio: ${stringRatio.toStringAsFixed(2)}% of original size');

      print('\n========== SIZE COMPARISON ==========');
      print('Original JSON: ${formatNumber(originalSize)} bytes (100%)');
      print('Binary compressed: ${formatNumber(compressedSize)} bytes (${compressionRatio.toStringAsFixed(2)}%)');
      print('Base64 encoded: ${formatNumber(stringSize)} bytes (${stringRatio.toStringAsFixed(2)}%)');

      // Verify round-trip integrity
      final ShrunkPayload decoded = ShrinkUtils.decodeWithLengthPrefix(base64String);
      final String decodedJson = utf8.decode(decoded.data);
      final inventoryDecoded = InventoryTest.fromJson(jsonDecode(decodedJson));

      expect(decoded.length, equals(originalSize));
      expect(inventoryDecoded.items.length, equals(inventory.items.length));

      // Verify all IDs match
      final Set<int> originalIds = inventory.items.map((item) => item.id).toSet();
      final Set<int> decodedIds = inventoryDecoded.items.map((item) => item.id).toSet();
      expect(decodedIds, equals(originalIds));

      print('\n========== VALIDATION ==========');
      print('✓ Round-trip encoding/decoding successful');
      print('✓ Original size preserved: ${formatNumber(originalSize)} bytes');
      print('✓ All ${inventory.items.length} unique object IDs preserved');
      print('=======================================\n');
    });
  });
}

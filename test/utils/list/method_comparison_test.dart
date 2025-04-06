import 'package:test/test.dart';
import 'package:shrink/utils/list/methods/methods.dart';

import '../list_test_data_generator.dart';

void main() {
  group('List Compression Method Comparison', () {
    test('Compare methods with various datasets', () {
      final datasets = [
        _DatasetInfo('Empty List', [], 'Empty list edge case'),
        _DatasetInfo('Single Value', [42], 'Single value edge case'),
        _DatasetInfo('Small Sorted List', [1, 5, 10, 15, 20], 'Small list of unique values'),
        _DatasetInfo('Sequential Values', List.generate(1000, (i) => i), 'Perfect sequential values (ideal for run-length)'),
        _DatasetInfo('Sparse List - Low', ListTestDataGenerator.generateSparseList(size: 1000, sparsity: 5.0), 'Sparse distribution with low sparsity'),
        _DatasetInfo('Sparse List - Medium', ListTestDataGenerator.generateSparseList(size: 1000, sparsity: 20.0), 'Sparse distribution with medium sparsity'),
        _DatasetInfo('Sparse List - High', ListTestDataGenerator.generateSparseList(size: 1000, sparsity: 100.0), 'Sparse distribution with high sparsity'),
        _DatasetInfo('Chunked List - Small Chunks', ListTestDataGenerator.generateChunkedList(size: 1000, chunkSize: 5, gapRatio: 2.0),
            'Small chunks of consecutive values'),
        _DatasetInfo('Chunked List - Medium Chunks', ListTestDataGenerator.generateChunkedList(size: 1000, chunkSize: 20, gapRatio: 2.0),
            'Medium chunks of consecutive values'),
        _DatasetInfo('Chunked List - Large Chunks', ListTestDataGenerator.generateChunkedList(size: 1000, chunkSize: 50, gapRatio: 2.0),
            'Large chunks of consecutive values'),
        _DatasetInfo(
            'Mixed Distribution',
            ListTestDataGenerator.generateCustomList(size: 1000, sparsity: 10.0, chunkSize: 20, gapRatio: 3.0, chunkProbability: 0.7),
            'Mix of chunks and sparse values'),
        _DatasetInfo('Large Unique List', ListTestDataGenerator.generateSortedUniqueList(size: 5000, maxValue: 100000), 'Large list with unique values'),
        _DatasetInfo('Very Large List', ListTestDataGenerator.generateSortedUniqueList(size: 10000, maxValue: 1000000), 'Very large list with unique values'),
      ];

      // Test each dataset with all encoding methods
      for (final dataset in datasets) {
        final results = _compareAllMethods(dataset.data);

        // Print result table for this dataset
        print('\n${dataset.name} (${dataset.data.length} items): ${dataset.description}');
        print('| Method      | No shrink size | Shrink size | Compression Ratio | Correct |');
        print('|-------------|---------------|-------------|-------------------|---------|');

        for (final result in results) {
          final ratio = result.originalSize > 0 ? '${(result.compressedSize / result.originalSize * 100).toStringAsFixed(2)}%' : 'N/A';

          print('| ${result.methodName.padRight(11)} | '
              '${result.originalSize.toString().padRight(13)} | '
              '${result.compressedSize.toString().padRight(11)} | '
              '${ratio.padRight(17)} | '
              '${result.correct ? '✅' : '❌'} |');
        }
      }
    });
  });
}

class _DatasetInfo {
  final String name;
  final List<int> data;
  final String description;

  _DatasetInfo(this.name, this.data, this.description);
}

class _EncodingResult {
  final String methodName;
  final int originalSize;
  final int compressedSize;
  final bool correct;

  _EncodingResult({
    required this.methodName,
    required this.originalSize,
    required this.compressedSize,
    required this.correct,
  });
}

List<_EncodingResult> _compareAllMethods(List<int> data) {
  // Calculate original size (4 bytes per integer)
  final originalSize = data.length * 4;

  final results = <_EncodingResult>[];

  // Test Bitmask encoding
  try {
    final encoded = encodeBitmask(data);
    final decoded = decodeBitmask(encoded);
    final correct = _listsEqual(data, decoded);

    results.add(_EncodingResult(
      methodName: 'Bitmask',
      originalSize: originalSize,
      compressedSize: encoded.length,
      correct: correct,
    ));
  } catch (e) {
    results.add(_EncodingResult(
      methodName: 'Bitmask',
      originalSize: originalSize,
      compressedSize: 0,
      correct: false,
    ));
  }

  // Test Delta-Varint encoding
  try {
    final encoded = encodeDeltaVarint(data);
    final decoded = decodeDeltaVarint(encoded);
    final correct = _listsEqual(data, decoded);

    results.add(_EncodingResult(
      methodName: 'Delta-Varint',
      originalSize: originalSize,
      compressedSize: encoded.length,
      correct: correct,
    ));
  } catch (e) {
    results.add(_EncodingResult(
      methodName: 'Delta-Varint',
      originalSize: originalSize,
      compressedSize: 0,
      correct: false,
    ));
  }

  // Test Run-Length encoding
  try {
    final encoded = encodeRuns(data);
    final decoded = decodeRuns(encoded);

    // For run-length, compare sets since the exact order/duplicates might not be preserved
    final correct = _setsEqual(data, decoded);

    results.add(_EncodingResult(
      methodName: 'Run-Length',
      originalSize: originalSize,
      compressedSize: encoded.length,
      correct: correct,
    ));
  } catch (e) {
    results.add(_EncodingResult(
      methodName: 'Run-Length',
      originalSize: originalSize,
      compressedSize: 0,
      correct: false,
    ));
  }

  // Test Chunked encoding
  try {
    final encoded = encodeChunked(data);
    final decoded = decodeChunked(encoded);
    final correct = _listsEqual(data, decoded);

    results.add(_EncodingResult(
      methodName: 'Chunked',
      originalSize: originalSize,
      compressedSize: encoded.length,
      correct: correct,
    ));
  } catch (e) {
    results.add(_EncodingResult(
      methodName: 'Chunked',
      originalSize: originalSize,
      compressedSize: 0,
      correct: false,
    ));
  }

  return results;
}

bool _listsEqual(List<int> list1, List<int> list2) {
  if (list1.length != list2.length) return false;

  // Sort both lists to handle cases where order doesn't matter
  list1 = [...list1]..sort();
  list2 = [...list2]..sort();

  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) return false;
  }

  return true;
}

// Compare sets of integers (ignoring duplicates and order)
bool _setsEqual(List<int> list1, List<int> list2) {
  return list1.toSet().difference(list2.toSet()).isEmpty && list2.toSet().difference(list1.toSet()).isEmpty;
}

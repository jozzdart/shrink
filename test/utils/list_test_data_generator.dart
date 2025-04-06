import 'dart:math';

/// Utility class to generate integer list test data for list compression tests
class ListTestDataGenerator {
  static final _random = Random();

  /// Generate a sorted list of integers with no duplicates
  /// size: approximate number of elements
  /// maxValue: maximum possible value (exclusive)
  static List<int> generateSortedUniqueList({
    required int size,
    required int maxValue,
  }) {
    final set = <int>{};
    while (set.length < size) {
      set.add(_random.nextInt(maxValue));
    }
    final list = set.toList()..sort();
    return list;
  }

  /// Generate a sparse list of integers (with large gaps)
  /// size: approximate number of elements
  /// sparsity: higher values create more sparse lists (should be > 1)
  /// maxValue is determined by size * sparsity
  static List<int> generateSparseList({
    required int size,
    required double sparsity,
  }) {
    assert(sparsity > 1.0, 'Sparsity factor should be greater than 1.0');
    final maxValue = (size * sparsity).toInt();
    final set = <int>{};

    while (set.length < size) {
      set.add(_random.nextInt(maxValue));
    }

    final list = set.toList()..sort();
    return list;
  }

  /// Generate a list with chunks of consecutive integers separated by gaps
  /// size: approximate number of elements
  /// chunkSize: average size of consecutive chunks
  /// gapRatio: determines how large the gaps are between chunks (higher = larger gaps)
  static List<int> generateChunkedList({
    required int size,
    required int chunkSize,
    required double gapRatio,
  }) {
    final List<int> result = [];
    int currentValue = _random.nextInt(100); // Start at a random position

    while (result.length < size) {
      // Generate a chunk of consecutive integers
      final actualChunkSize = max(1, chunkSize + _random.nextInt(5) - 2); // Some variation
      for (int i = 0; i < actualChunkSize && result.length < size; i++) {
        result.add(currentValue++);
      }

      // Add a gap before the next chunk
      final gapSize = (actualChunkSize * gapRatio).ceil();
      currentValue += max(1, _random.nextInt(gapSize * 2));
    }

    return result;
  }

  /// Generate test cases with different list sizes
  static List<List<int>> generateTestCases() {
    return [
      // Empty list
      [],

      // Single element
      [42],

      // Small lists
      generateSortedUniqueList(size: 10, maxValue: 100),

      // Medium lists
      generateSortedUniqueList(size: 100, maxValue: 1000),
      generateSparseList(size: 100, sparsity: 10.0),
      generateChunkedList(size: 100, chunkSize: 5, gapRatio: 2.0),

      // Large lists with different characteristics
      generateSortedUniqueList(size: 1000, maxValue: 10000),
      generateSparseList(size: 1000, sparsity: 5.0),
      generateSparseList(size: 1000, sparsity: 20.0),
      generateChunkedList(size: 1000, chunkSize: 10, gapRatio: 1.5),
      generateChunkedList(size: 1000, chunkSize: 50, gapRatio: 3.0),

      // Very large lists
      generateSortedUniqueList(size: 5000, maxValue: 100000),
      generateSparseList(size: 5000, sparsity: 10.0),
      generateChunkedList(size: 5000, chunkSize: 100, gapRatio: 2.0),

      // Extremely large list
      generateSortedUniqueList(size: 10000, maxValue: 1000000),
    ];
  }

  /// Generate a custom test case
  static List<int> generateCustomList({
    required int size,
    required double sparsity,
    required int chunkSize,
    required double gapRatio,
    required double chunkProbability,
  }) {
    final List<int> result = [];
    int currentValue = 0;

    while (result.length < size) {
      // Decide whether to add a chunk or a sparse value
      if (_random.nextDouble() < chunkProbability) {
        // Add a chunk of consecutive values
        final actualChunkSize = max(1, chunkSize + _random.nextInt(5) - 2);
        for (int i = 0; i < actualChunkSize && result.length < size; i++) {
          result.add(currentValue++);
        }

        // Add a gap after the chunk
        final gapSize = (actualChunkSize * gapRatio).ceil();
        currentValue += max(1, _random.nextInt(gapSize));
      } else {
        // Add a sparse value
        currentValue += max(1, (_random.nextInt((sparsity * 10).toInt()) + 1));
        result.add(currentValue++);
      }
    }

    return result;
  }

  /// Generate increasingly sparse test cases (useful for benchmarking)
  static List<List<int>> generateSparsenessSeries({
    required int size,
    required List<double> sparsityFactors,
  }) {
    return sparsityFactors.map((factor) => generateSparseList(size: size, sparsity: factor)).toList();
  }

  /// Generate increasingly chunked test cases (useful for benchmarking)
  static List<List<int>> generateChunkSizeSeries({
    required int size,
    required List<int> chunkSizes,
    required double gapRatio,
  }) {
    return chunkSizes.map((chunkSize) => generateChunkedList(size: size, chunkSize: chunkSize, gapRatio: gapRatio)).toList();
  }
}

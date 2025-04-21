import 'table_logger.dart';

/// Represents a dataset used for comparison
class DatasetInfo {
  final String name;
  final List<int> data;
  final String description;

  DatasetInfo(this.name, this.data, this.description);

  /// Returns a formatted name with item count (if available)
  String get formattedName {
    return '$name (${data.length} items)';
  }
}

/// Represents a compression method result
class CompressionResult {
  final String methodName;
  final int originalSize;
  final int compressedSize;
  final bool correct;

  CompressionResult({
    required this.methodName,
    required this.originalSize,
    required this.compressedSize,
    required this.correct,
  });

  /// Calculate compression ratio as a percentage
  String get compressionRatio {
    if (originalSize <= 0) return 'N/A';
    return '${(compressedSize / originalSize * 100).toStringAsFixed(2)}%';
  }

  /// Calculate space saved as a percentage
  String get spaceSaved {
    if (originalSize <= 0) return 'N/A';
    return '${((1 - compressedSize / originalSize) * 100).toStringAsFixed(2)}%';
  }

  /// Calculate compression factor (e.g., 5X for 20% of original size)
  String get compressionFactor {
    if (originalSize <= 0 || compressedSize <= 0) return 'N/A';
    return '${(originalSize / compressedSize).toStringAsFixed(2)}X';
  }

  /// Convert to a Map for use with TableLogger
  Map<String, dynamic> toMap() {
    return {
      'methodName': methodName,
      'originalSize': originalSize,
      'compressedSize': compressedSize,
      'compressionRatio': compressionRatio,
      'spaceSaved': spaceSaved,
      'compressionFactor': compressionFactor,
      'correct': correct ? '✅' : '❌',
    };
  }
}

/// Utility class for logging compression method comparisons
class CompressionLogger {
  /// Logs compression method comparison results for a dataset
  static List<String> logCompressionResults({
    required DatasetInfo dataset,
    required List<CompressionResult> results,
    bool includeSpaceSaved = true,
    bool includeCompressionFactor = true,
  }) {
    final columns = [
      'methodName',
      'originalSize',
      'compressedSize',
      'compressionRatio',
      if (includeSpaceSaved) 'spaceSaved',
      if (includeCompressionFactor) 'compressionFactor',
      'correct',
    ];

    final columnLabels = {
      'methodName': 'Method',
      'originalSize': 'Original Size',
      'compressedSize': 'Compressed Size',
      'compressionRatio': 'Compression Ratio',
      'spaceSaved': 'Space Saved',
      'compressionFactor': 'Comp. Factor',
      'correct': 'Correct',
    };

    final resultMaps = results.map((r) => r.toMap()).toList();

    var table = TableLogger.printMethodComparisonTable(
      title: dataset.formattedName,
      description: dataset.description,
      results: resultMaps,
      columns: columns,
      columnLabels: columnLabels,
    );

    return table;
  }

  /// Logs compression results for multiple datasets
  static List<String> logMultipleDatasetResults({
    required List<DatasetInfo> datasets,
    required Map<DatasetInfo, List<CompressionResult>> allResults,
    bool includeSpaceSaved = true,
    bool includeCompressionFactor = true,
  }) {
    List<String> logs = [];

    for (final dataset in datasets) {
      final results = allResults[dataset];
      if (results != null) {
        var toAdd = logCompressionResults(
          dataset: dataset,
          results: results,
          includeSpaceSaved: includeSpaceSaved,
          includeCompressionFactor: includeCompressionFactor,
        );

        logs.addAll(toAdd);
      }
    }

    return logs;
  }
}

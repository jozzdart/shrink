import 'dart:convert';
import 'table_logger.dart';

class DataSizeLogger {
  /// Logs size comparisons for data in different formats (JSON, bytes, text)
  static List<String> logDataSizeComparison({
    required String name,
    required dynamic originalData,
    required dynamic shrunkData,
    String description = '',
  }) {
    // Calculate sizes and metrics
    final results = _calculateSizeMetrics(
      name: name,
      originalData: originalData,
      shrunkData: shrunkData,
      description: description,
    );

    // Convert results to a format suitable for TableLogger
    final headers = [
      'Format',
      'Original Size',
      'Shrunk Size',
      'Compression Ratio',
      'Space Saved',
      'Compression Factor'
    ];

    final rows = results
        .map((result) => [
              result.format,
              result.originalSize.toString(),
              result.shrunkSize.toString(),
              result.compressionRatio,
              result.spaceSaved,
              result.compressionFactor,
            ])
        .toList();

    // Use TableLogger to print the table
    var table = TableLogger.printTable(
      title: name,
      description: description,
      headers: headers,
      rows: rows,
      dynamicRows: true,
    );

    return table;
  }

  /// Calculates size metrics for different data formats
  static List<_SizeMetricsResult> _calculateSizeMetrics({
    required String name,
    required dynamic originalData,
    required dynamic shrunkData,
    required String description,
  }) {
    final results = <_SizeMetricsResult>[];

    // JSON format
    try {
      final originalJsonStr = jsonEncode(originalData);
      final shrunkJsonStr = jsonEncode(shrunkData);

      final originalSize = originalJsonStr.length;
      final shrunkSize = shrunkJsonStr.length;

      results.add(_createMetricsResult('JSON', originalSize, shrunkSize));
    } catch (e) {
      results.add(_createErrorResult('JSON'));
    }

    // Bytes format (if applicable)
    try {
      List<int> originalBytes;
      List<int> shrunkBytes;

      if (originalData is List<int>) {
        originalBytes = originalData;
      } else if (originalData is String) {
        originalBytes = utf8.encode(originalData);
      } else {
        originalBytes = utf8.encode(jsonEncode(originalData));
      }

      if (shrunkData is List<int>) {
        shrunkBytes = shrunkData;
      } else if (shrunkData is String) {
        shrunkBytes = utf8.encode(shrunkData);
      } else {
        shrunkBytes = utf8.encode(jsonEncode(shrunkData));
      }

      final originalSize = originalBytes.length;
      final shrunkSize = shrunkBytes.length;

      results.add(_createMetricsResult('Bytes', originalSize, shrunkSize));
    } catch (e) {
      results.add(_createErrorResult('Bytes'));
    }

    // Text format (if applicable)
    try {
      String originalText;
      String shrunkText;

      if (originalData is String) {
        originalText = originalData;
      } else {
        originalText = originalData.toString();
      }

      if (shrunkData is String) {
        shrunkText = shrunkData;
      } else {
        shrunkText = shrunkData.toString();
      }

      final originalSize = originalText.length;
      final shrunkSize = shrunkText.length;

      results.add(_createMetricsResult('Text', originalSize, shrunkSize));
    } catch (e) {
      results.add(_createErrorResult('Text'));
    }

    return results;
  }

  /// Creates a metrics result with calculated values
  static _SizeMetricsResult _createMetricsResult(
      String format, int originalSize, int shrunkSize) {
    final ratio = originalSize > 0 ? shrunkSize / originalSize : 0.0;
    final compressionRatio = '${(ratio * 100).toStringAsFixed(2)}%';
    final spaceSaved = '${((1 - ratio) * 100).toStringAsFixed(2)}%';
    final factor = ratio > 0 ? '${(1 / ratio).toStringAsFixed(2)}X' : 'N/A';

    return _SizeMetricsResult(
      format: format,
      originalSize: originalSize,
      shrunkSize: shrunkSize,
      compressionRatio: compressionRatio,
      spaceSaved: spaceSaved,
      compressionFactor: factor,
    );
  }

  /// Creates an error result for when calculation fails
  static _SizeMetricsResult _createErrorResult(String format) {
    return _SizeMetricsResult(
      format: format,
      originalSize: 0,
      shrunkSize: 0,
      compressionRatio: 'N/A',
      spaceSaved: 'N/A',
      compressionFactor: 'N/A',
    );
  }
}

/// Helper class to store size metrics results
class _SizeMetricsResult {
  final String format;
  final int originalSize;
  final int shrunkSize;
  final String compressionRatio;
  final String spaceSaved;
  final String compressionFactor;

  _SizeMetricsResult({
    required this.format,
    required this.originalSize,
    required this.shrunkSize,
    required this.compressionRatio,
    required this.spaceSaved,
    required this.compressionFactor,
  });
}

import 'dart:math' as math;

/// Utility for creating and printing formatted tables in test logs
class TableLogger {
  /// Creates and prints a table with headers and rows
  ///
  /// [title] - The title of the table (optional)
  /// [description] - Additional description for the table (optional)
  /// [headers] - List of column headers
  /// [rows] - List of rows, each row being a list of values matching the headers
  /// [columnWidths] - Optional fixed widths for columns (if not provided, will be calculated)
  /// [dynamicRows] - If true, rows will expand based on actual content (default: true)
  static List<String> printTable({
    String? title,
    String? description,
    required List<String> headers,
    required List<List<dynamic>> rows,
    List<int>? columnWidths,
    bool dynamicRows = true,
  }) {
    List<String> toReturn = [];

    if (title != null || description != null) {
      final titleText = [
        if (title != null) title,
        if (title != null && description != null) ': ',
        if (description != null) description,
      ].join('');

      toReturn.add(titleText);
    }

    // Calculate column widths if not provided
    final widths = columnWidths ?? _calculateColumnWidths(headers, rows);

    // Print header row
    var header = _printHeaderRow(headers, widths);
    toReturn.add(header);

    // Print separator row with same formatting approach as the rows
    var separator = dynamicRows ? _printDynamicSeparatorRow(headers, widths) : _printFixedSeparatorRow(widths);
    toReturn.add(separator);

    // Print data rows
    for (final row in rows) {
      var rowsToAdd = dynamicRows ? _printDynamicRow(row, widths, headers.length) : _printFixedRow(row, widths);
      toReturn.add(rowsToAdd);
    }

    return toReturn;
  }

  /// Convenience method to create a comparison table with method/algorithm performance
  static List<String> printMethodComparisonTable({
    String? title,
    String? description,
    required List<Map<String, dynamic>> results,
    required List<String> columns,
    Map<String, String>? columnLabels,
    bool dynamicRows = true,
  }) {
    // Generate headers from column labels or default to column names
    final headers = columns.map((col) => columnLabels?[col] ?? col).toList();

    // Generate rows from results
    final rows = results.map((result) => columns.map((col) => result[col]).toList()).toList();

    final toReturn = printTable(
      title: title,
      description: description,
      headers: headers,
      rows: rows,
      dynamicRows: dynamicRows,
    );

    return toReturn;
  }

  /// For method/algorithm comparison with fixed columns
  static List<String> printCompressionResults({
    required String name,
    required String? description,
    required List<Map<String, dynamic>> results,
    bool showCorrectness = true,
    bool dynamicRows = true,
  }) {
    final columns = [
      'methodName',
      'originalSize',
      'compressedSize',
      'compressionRatio',
      if (showCorrectness) 'correct',
    ];

    final columnLabels = {
      'methodName': 'Method',
      'originalSize': 'Original Size',
      'compressedSize': 'Compressed Size',
      'compressionRatio': 'Compression Ratio',
      'correct': 'Correct',
    };

    final toReturn = printMethodComparisonTable(
      title: name,
      description: description,
      results: results,
      columns: columns,
      columnLabels: columnLabels,
      dynamicRows: dynamicRows,
    );

    return toReturn;
  }

  /// Calculate appropriate column widths based on data
  static List<int> _calculateColumnWidths(List<String> headers, List<List<dynamic>> rows) {
    final widths = List<int>.filled(headers.length, 0);

    // Consider header widths
    for (int i = 0; i < headers.length; i++) {
      widths[i] = headers[i].length;
    }

    // Consider data widths
    for (final row in rows) {
      for (int i = 0; i < row.length && i < widths.length; i++) {
        final cellWidth = row[i].toString().length;
        if (cellWidth > widths[i]) {
          widths[i] = cellWidth;
        }
      }
    }

    // Add padding
    return widths.map((w) => w + 2).toList();
  }

  /// Print a formatted header row
  static String _printHeaderRow(List<String> headers, List<int> widths) {
    final parts = <String>[];

    for (int i = 0; i < headers.length; i++) {
      final header = headers[i];
      final width = i < widths.length ? widths[i] : header.length + 2;
      parts.add('| ${header.padRight(width - 2)} ');
    }

    return ('${parts.join('')}|');
  }

  /// Print a separator row for fixed width tables
  static String _printFixedSeparatorRow(List<int> widths) {
    final parts = <String>[];

    for (int width in widths) {
      parts.add('|${'-' * (width + 1)}');
    }

    return ('${parts.join('')}|');
  }

  /// Print a separator row that matches the dynamic header row format
  static String _printDynamicSeparatorRow(List<String> headers, List<int> widths) {
    final parts = <String>[];

    for (int i = 0; i < headers.length; i++) {
      final width = i < widths.length ? widths[i] : headers[i].length + 2;
      // Match the exact pattern of header/data rows: "| content "
      parts.add('|-${'-'.padRight(width - 2, '-')} ');
    }

    return ('${parts.join('')}|');
  }

  /// Print a formatted row with fixed column widths
  static String _printFixedRow(List<dynamic> row, List<int> widths) {
    final parts = <String>[];

    for (int i = 0; i < row.length; i++) {
      final cell = row[i].toString();
      final width = i < widths.length ? widths[i] : cell.length + 2;
      parts.add('| ${cell.padRight(width - 2)} ');
    }

    return ('${parts.join('')}|');
  }

  /// Print a row with content-based widths (expands for actual content)
  static String _printDynamicRow(List<dynamic> row, List<int> minWidths, int headerCount) {
    final parts = <String>[];

    for (int i = 0; i < row.length; i++) {
      final cell = row[i].toString();
      // Calculate width based on actual content, but ensure it's at least as wide as the header
      final minWidth = i < minWidths.length ? minWidths[i] : 2;

      // Special handling for emoji to ensure consistent width
      final isEmoji = _containsEmoji(cell);
      final cellWidth = isEmoji ? minWidth : math.max(cell.length + 2, minWidth);

      parts.add('| ${cell.padRight(cellWidth - 2)} ');
    }

    // Add any missing columns (if the row has fewer cells than headers)
    for (int i = row.length; i < headerCount; i++) {
      final width = i < minWidths.length ? minWidths[i] : 2;
      parts.add('| ${' '.padRight(width - 2)} ');
    }

    return ('${parts.join('')}|');
  }

  /// Check if a string contains emoji characters
  static bool _containsEmoji(String text) {
    // Simple check for common emojis used in the app (✅ and ❌)
    return text.contains('✅') || text.contains('❌');
  }
}

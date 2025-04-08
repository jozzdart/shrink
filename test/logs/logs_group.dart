class LogsGroup {
  List<String> _logs;
  final String _separator = '=' * 80; // Separator line for test case output

  LogsGroup(this._logs);

  bool get isEmpty => _logs.isEmpty;

  factory LogsGroup.empty() {
    return LogsGroup([]);
  }

  void addLog(String log) {
    _logs.add(log);
  }

  void addLogs(List<String> logs) {
    for (var i = 0; i < logs.length; i++) {
      _logs.add(logs[i]);
    }
  }

  void printAll() {
    // Add separator before printing logs
    print(_separator);

    // Create a copy of logs to print
    final logsToPrint = List<String>.from(_logs);
    _logs.clear(); // Clear the original list

    // Print all logs
    for (var log in logsToPrint) {
      print(log);
    }

    // Add separator after printing logs
    print(_separator);
    print(''); // Add extra newline for better readability
  }
}

import 'dart:convert';
import 'dart:io';

/// Helper class to load test files from the `test/data/` folder.
class TestDataLoader {
  static final String _basePath = '${Directory.current.path}\\test\\data';

  /// Loads a file from the `test/data/` folder as a string.
  static Future<String> getFile(String name) async {
    final file = File('$_basePath\\$name');
    return await file.readAsString();
  }

  /// Loads and parses a JSON file from the `test/data/` folder.
  static Future<Map<String, dynamic>> getJson(String name) async {
    final content = await getFile('$name.json');
    return jsonDecode(content);
  }
}

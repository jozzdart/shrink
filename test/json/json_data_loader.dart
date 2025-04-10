import '../data/test_data_loader.dart';

class JsonDataLoader {
  static String prefix = 'generated';

  /// Loads a JSON file with the given index.
  /// Returns the decoded JSON content.
  static Future<dynamic> loadJson({int index = 1}) async {
    return await TestDataLoader.getJson('$prefix$index');
  }
}

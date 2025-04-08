import '../data/test_data_loader.dart';

class JsonDataLoader {
  static String prefix = 'generated';

  static Future<Map<String, dynamic>> loadJson({int index = 1}) async {
    return await TestDataLoader.getJson('$prefix$index');
  }
}

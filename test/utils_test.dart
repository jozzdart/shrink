import 'package:test/test.dart';

import 'utils/text_test.dart' as text_test;
import 'utils/size_test.dart' as size_test;
import 'utils/json_test.dart' as json_test;
import 'utils/bytes_test.dart' as bytes_test;

void main() {
  group('Text Utils', () {
    text_test.main();
  });

  group('Size Utils', () {
    size_test.main();
  });

  group('JSON Utils', () {
    json_test.main();
  });

  group('Bytes Utils', () {
    bytes_test.main();
  });
}

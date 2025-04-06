import 'package:test/test.dart';

import 'bitmask_test.dart' as bitmask_test;
import 'variant_test.dart' as variant_test;
import 'runlength_test.dart' as runlength_test;
import 'chunked_test.dart' as chunked_test;
import 'method_comparison_test.dart' as comparison_test;

void main() {
  group('List Compression Tests', () {
    group('Bitmask Tests', bitmask_test.main);
    group('Delta-Varint Tests', variant_test.main);
    group('Run-Length Tests', runlength_test.main);
    group('Chunked Tests', chunked_test.main);
    group('Method Comparison', comparison_test.main);
  });
}

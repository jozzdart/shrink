import 'dart:typed_data';

import 'package:shrink/utils/utils.dart';

abstract class Restore {
  static Uint8List bytes(Uint8List compressed) {
    return restoreBytes(compressed);
  }

  static Map<String, dynamic> json(Uint8List compressed) {
    return restoreJson(compressed);
  }

  static String text(Uint8List compressed) {
    return restoreText(compressed);
  }

  static List<int> unique(Uint8List compressed) {
    return restoreUnique(compressed);
  }
}

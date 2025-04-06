import 'dart:typed_data';

import 'package:shrink/utils/utils.dart';

abstract class Shrink {
  static Uint8List bytes(Uint8List bytes) {
    return shrinkBytes(bytes);
  }

  static Uint8List json(Map<String, dynamic> json) {
    return shrinkJson(json);
  }

  static Uint8List text(String text) {
    return shrinkText(text);
  }

  static Uint8List unique(List<int> uniqueList) {
    return shrinkUnique(uniqueList);
  }
}

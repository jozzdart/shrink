import 'dart:convert';
import 'dart:typed_data';

import 'package:shrink/utils/utils.dart' as utils;

/// Extensions on [Uint8List] for shrinking operations
extension ShrinkExtensionsBytes on Uint8List {
  String toBase64() => base64Encode(this);
  String restoreText() => utils.restoreText(this);
  Uint8List restoreBytes() => utils.restoreBytes(this);
  Map<String, dynamic> restoreJson() => utils.restoreJson(this);
  List<int> restoreUnique() => utils.restoreUnique(this);
}

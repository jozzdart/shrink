import 'dart:convert';
import 'dart:typed_data';

import 'package:shrink/utils/utils.dart' as utils;

extension ShrinkExtensionsString on String {
  Uint8List shrinkText() => utils.shrinkText(this);
  Uint8List fromBase64() => base64Decode(this);
}

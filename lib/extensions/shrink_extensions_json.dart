import 'dart:typed_data';

import 'package:shrink/utils/utils.dart' as utils;

/// Extensions on [Uint8List] for shrinking operations
extension ShrinkExtensionsJson on Map<String, dynamic> {
  Uint8List shrinkJson() => utils.shrinkJson(this);
}

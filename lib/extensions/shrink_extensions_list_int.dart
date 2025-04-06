import 'dart:typed_data';

import 'package:shrink/utils/utils.dart' as utils;

extension ShrinkExtensionsListInt on List<int> {
  Uint8List shrinkUnique() => utils.shrinkUnique(this);
}

/// A lightweight library for efficient data compression and decompression.
///
/// The `shrink` library provides tools to easily compress and decompress different
/// data types including strings, byte arrays, JSON objects, and unique integer lists.
///
/// Use the top-level functions `shrink()` and `restore()` or use the `Shrink` and
/// `Restore` classes for a more object-oriented approach. This library also provides
/// convenient extensions on various data types for even simpler usage.
library shrink;

export 'utils/utils.dart';
export 'extensions/extensions.dart';
export 'core/core.dart';

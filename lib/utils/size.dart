import 'dart:convert';

/// Calculates the size in bytes of a string when encoded as UTF-8.
///
/// This is useful for determining how much space a string will occupy when
/// stored or transmitted in UTF-8 format, which is often different from
/// the string's character count due to multi-byte characters.
///
/// Returns the size in bytes.
int getStringSize(String text) {
  return utf8.encode(text).length;
}

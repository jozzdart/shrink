abstract class ShrinkCodec<T> {
  /// Encodes an object into a Firestore-safe string
  String encode(T value);

  /// Decodes from a string back into an object
  T decode(String encoded);
}

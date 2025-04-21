part of 'generators.dart';

/// Generate JSON test data sets of different complexities
List<Map<String, dynamic>> generateJsonTestData() {
  return [
    {}, // Empty
    {'key': 'value'}, // Simple
    {
      'nested': {'key': 'value'}
    }, // Nested
    {'array': List.generate(10, (i) => i)}, // With array
    randomJson(5), // Small random
    randomJson(20), // Medium random
    randomJson(50, maxDepth: 3), // Large random with deeper nesting
  ];
}

/// Generate a random JSON object with the specified number of keys
Map<String, dynamic> randomJson(int keyCount,
    {int maxDepth = 2, int currentDepth = 0}) {
  final result = <String, dynamic>{};

  for (int i = 0; i < keyCount; i++) {
    final key = 'key_${randomString(5)}';
    final valueType = random.nextInt(5);

    switch (valueType) {
      case 0: // String
        result[key] = randomString(10 + random.nextInt(20));
        break;
      case 1: // Number
        result[key] = random.nextDouble() * 1000;
        break;
      case 2: // Boolean
        result[key] = random.nextBool();
        break;
      case 3: // List
        if (currentDepth < maxDepth) {
          result[key] = List.generate(3 + random.nextInt(5),
              (_) => _randomJsonValue(maxDepth, currentDepth + 1));
        } else {
          result[key] = random.nextInt(100);
        }
        break;
      case 4: // Nested object
        if (currentDepth < maxDepth) {
          result[key] = randomJson(3 + random.nextInt(5),
              maxDepth: maxDepth, currentDepth: currentDepth + 1);
        } else {
          result[key] = randomString(10);
        }
        break;
    }
  }

  return result;
}

/// Generate a random JSON value
dynamic _randomJsonValue(int maxDepth, int currentDepth) {
  final valueType = random.nextInt(5);

  switch (valueType) {
    case 0: // String
      return randomString(5 + random.nextInt(10));
    case 1: // Number
      return random.nextDouble() * 100;
    case 2: // Boolean
      return random.nextBool();
    case 3: // List
      if (currentDepth < maxDepth) {
        return List.generate(2 + random.nextInt(3),
            (_) => _randomJsonValue(maxDepth, currentDepth + 1));
      } else {
        return random.nextInt(100);
      }
    case 4: // Nested object
      if (currentDepth < maxDepth) {
        return randomJson(2 + random.nextInt(3),
            maxDepth: maxDepth, currentDepth: currentDepth + 1);
      } else {
        return randomString(5);
      }
    default:
      return null;
  }
}

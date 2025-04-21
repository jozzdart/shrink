import 'dart:io';

void main() async {
  final source = File('shrink_core/README.md');
  final target = File('shrink_flutter/README.md');

  if (!await source.exists()) {
    stderr.writeln('❌ shrink_core/README.md not found.');
    exit(1);
  }

  final content = await source.readAsString();

  final result = '''
# shrink_flutter

🧩 Flutter utilities for [`shrink`](https://pub.dev/packages/shrink), including async compression and isolate-safe tools.

---

The following is adapted from the main [`shrink`](https://pub.dev/packages/shrink) documentation:

<!-- shrink:sync-start -->

$content

<!-- shrink:sync-end -->
''';

  await target.writeAsString(result);
  print('✅ shrink_flutter/README.md updated.');
}

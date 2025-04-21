import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shrink_flutter/shrink_flutter.dart'; // AShrink + ARestore

void main() {
  runApp(const ShrinkExampleApp());
}

class ShrinkExampleApp extends StatelessWidget {
  const ShrinkExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrink Async Example',
      home: const ShrinkExampleScreen(),
    );
  }
}

class ShrinkExampleScreen extends StatefulWidget {
  const ShrinkExampleScreen({super.key});

  @override
  State<ShrinkExampleScreen> createState() => _ShrinkExampleScreenState();
}

class _ShrinkExampleScreenState extends State<ShrinkExampleScreen> {
  String result = 'Running...';

  @override
  void initState() {
    super.initState();
    _runDemo();
  }

  Future<void> _runDemo() async {
    final buffer = StringBuffer();

    // 🔤 1. Compress & decompress text
    const originalText = 'Shrink is isolate-safe and async 🎉';
    final compressedText = await ShrinkAsync.text(originalText);
    final restoredText = await RestoreAsync.text(compressedText);
    buffer.writeln('🔤 Text:\n$restoredText');

    // 🧩 2. Compress & decompress JSON
    final originalJson = {
      'user': 'flutter_dev',
      'roles': ['admin', 'tester'],
      'features': {'darkMode': true, 'compression': 'shrink'},
    };
    final compressedJson = await ShrinkAsync.json(originalJson);
    final restoredJson = await RestoreAsync.json(compressedJson);
    buffer.writeln('\n🧩 JSON:\n$restoredJson');

    // 🔢 3. Compress & decompress unique int list
    final originalList = List.generate(1000, (i) => i * 2);
    final compressedList = await ShrinkAsync.unique(originalList);
    final restoredList = await RestoreAsync.unique(compressedList);
    buffer.writeln(
      '\n🔢 Unique List:\nMatch: ${_listEquals(originalList, restoredList)}',
    );

    // 📦 4. Compress & decompress raw bytes
    final rawString = 'Flutter ❤ Shrink!';
    final rawBytes = Uint8List.fromList(utf8.encode(rawString));
    final compressedBytes = await ShrinkAsync.bytes(rawBytes);
    final restoredBytes = await RestoreAsync.bytes(compressedBytes);
    buffer.writeln('\n📦 Raw Bytes:\n${utf8.decode(restoredBytes)}');

    setState(() {
      result = buffer.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shrink Async Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SelectableText(result),
      ),
    );
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

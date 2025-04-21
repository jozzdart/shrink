# shrink_flutter

🧩 Flutter utilities for [`shrink`](https://pub.dev/packages/shrink), including async compression and isolate-safe tools.

---

The following is adapted from the main [`shrink`](https://pub.dev/packages/shrink) documentation:

<!-- shrink:sync-start -->

![img](https://i.imgur.com/96jsfqo.png)

<h3 align="center"><i>Because every byte counts.</i></h3>
<p align="center">
        <img src="https://img.shields.io/codefactor/grade/github/jozzzzep/shrink/main?style=flat-square">
        <img src="https://img.shields.io/github/license/jozzzzep/shrink?style=flat-square">
        <img src="https://img.shields.io/pub/points/shrink?style=flat-square">
        <img src="https://img.shields.io/pub/v/shrink?style=flat-square">
</p>

Compress any data in one line — no setup, no boilerplate, and nothing to configure. It automatically detects if compression is beneficial, chooses the most efficient method, and keeps everything fully lossless. Typical savings range from 5× to 40×, and can reach 1,000× or more with structured data. Ideal for reducing size in Firebase, speeding up local storage, and optimizing for low-bandwidth environments.

- [Introduction](#-shrink-anything-in-one-line)
- [What can I shrink?!](#what-can-i-shrink)
- [All functions per data](#-extension-api-shrink--restorex)
- [Benchmarks](#-benchmarks)
- [How It Works Under the Hood](#-how-it-works-under-the-hood)
- [Testing & Validation](#-testing--validation)
- [Firebase Integration Example](#-firebase-integration-example)
- [Beginner's Guide: Step-by-Step Setup & Usage](#-beginners-guide-step-by-step-setup--usage)
- [Roadmap & Future Plans](#-roadmap--future-plans)

---

### ✨ Shrink Anything in One Line

Compression is as easy as calling `.shrink()` on your data — no setup, no boilerplate.

```dart
final compressed = data.shrink(); // ⬇️ Compress your data
```

Or use the static `Shrink` class for clarity:

```dart
final compressed = Shrink.json(data);
```

> Works with: `String`, `Map<String, dynamic>`, `Uint8List`, and `List<int>` (unique IDs)

---

### 🔓 Restore Instantly

To get your original data back, just call `.restoreX()` on the compressed value:

```dart
final restored = compressed.restoreJson(); // ⬆️ Restore original content
```

Or use the static `Restore` class:

```dart
final restored = Restore.json(compressed);
```

> Every `shrink` operation is **lossless** — the restored value is identical to the original.

# What Can I Shrink?!

> Real-world data — from network packets to text content — is rarely random. It contains patterns and structure that enable efficient compression. In typical use, shrink reduces data size by 5× to 10×. With highly structured data, compression can reach 100× or even 1,000× smaller. For example, a 1MB list of sequential IDs can shrink to just a few bytes.

#### 🔢 `List<int>` (Unique Integers)

- Perfect for ID lists like inventory items, selected flags, indexes, or any sparse/sequential keys. Optimized for sets of non-repeating integers.

#### 🧠 `Uint8List` (Raw Bytes)

- Great for custom compression workflows — convert anything to bytes and shrink it efficiently. Ideal for binary data or serialized formats.

#### ✍️ `String` (Text)

- Compress plain text directly and restore it back as a String. Works well for logs, messages, descriptions, or long content fields.

#### 📦 `Map<String, dynamic>` (JSON)

- Shrinks any Map<String, dynamic> by compressing the serialized string. Especially useful for structured or repetitive data — great for Firebase, config files, and API payloads.

---

- Shrink any supported data using the extension or static API.
- Don’t shrink twice — it just adds a byte.
- Use the correct restore method for the data type.

### ✅ Extension API (`.shrink()` → `.restoreX()`)

| Data Type         | Shrink           | Restore                    |
| ----------------- | ---------------- | -------------------------- |
| Unique Integers   | `items.shrink()` | `shrinked.restoreUnique()` |
| Text (String)     | `text.shrink()`  | `shrinked.restoreText()`   |
| JSON (Map)        | `data.shrink()`  | `shrinked.restoreJson()`   |
| Bytes (Uint8List) | `bytes.shrink()` | `shrinked.restoreBytes()`  |

### 🧱 Static API (`Shrink.x()` → `Restore.x()`)

| Data Type         | Shrink                 | Restore                    |
| ----------------- | ---------------------- | -------------------------- |
| Unique Integers   | `Shrink.unique(items)` | `Restore.unique(shrinked)` |
| Text (String)     | `Shrink.text(text)`    | `Restore.text(shrinked)`   |
| JSON (Map)        | `Shrink.json(data)`    | `Restore.json(shrinked)`   |
| Bytes (Uint8List) | `Shrink.bytes(bytes)`  | `Restore.bytes(shrinked)`  |

---

### ⬇️ Shrinking in code

```dart
final shrinkedItems = items.shrink();
final shrinkedText  = text.shrink();
final shrinkedJson  = data.shrink();
final shrinkedBytes = data.shrink()
```

Or use the static `Shrink` class for a clean, explicit API:

```dart
final shrinkedItems = Shrink.unique(items);
final shrinkedText  = Shrink.text(text);
final shrinkedJson  = Shrink.json(data);
final shrinkedBytes = Shrink.bytes(bytes);
```

### 🔓 Restoring in code

Easily restore compressed data using `.restoreX()`:

```dart
final restoredItems = shrinkedItems.restoreUnique();
final restoredText  = shrinkedText.restoreText();
final restoredJson  = shrinkedJson.restoreJson();
final restoredBytes = shrinkedBytes.restoreBytes();
```

Or with the static `Restore` class:

```dart
final restoredItems = Restore.unique(shrinkedItems);
final restoredText  = Restore.text(shrinkedText);
final restoredJson  = Restore.json(shrinkedJson);
final restoredBytes = Restore.bytes(shrinkedBytes);
```

# 📊 Benchmarks

> 🛡 **Built for the long haul.**  
> When `shrink` gets faster, smaller, and smarter — **you don’t have to lift a finger**.  
> Every version in the `1.x.x` line is fully **backward compatible**.  
> Your existing data will always decompress perfectly, no matter how the internals evolve.  
> Just update and enjoy the gains — **no migrations, no breakage, no surprises**.

`shrink` has been benchmarked with a variety of real-world data scenarios, including:

- Raw bytes: random, repetitive, alternating, zero-filled
- JSON: flat, nested, arrays, and complex structures
- Lists of unique integers: sequential, sparse, dense, and special patterns

Compression results vary depending on the input but can reach up to **200,000×** reduction in size. All tests are validated and performance-logged.

### 🧩 Bytes & Text Shrinking

In almost every real-world scenario — from network packets and sensor logs to text content and protocol buffers — **data is not truly random**. Even when it _appears_ non-repetitive at a low level, real data almost always contains some form of structure, patterns, or repetition:

- **Character frequency** in text (e.g., spaces, vowels, tags)
- **Binary signatures** in files and headers
- **Zero-padded or default values** in structured formats
- **Protocol overhead** in serialized data

That’s why compression can be so effective even on data that doesn’t look obviously redundant.

Shrink leverages this reality and combines compression strategies to achieve significant reductions for most data types.

---

## 📦 Compression Results (Bytes & Text)

| Data Pattern      | Input Size (Bytes) | Shrink Size | Space Saved | Factor    |
| ----------------- | ------------------ | ----------- | ----------- | --------- |
| Random (1KB)      | 1,000              | 1,001       | `None`      | `No gain` |
| Repetitive (1KB)  | 1,000              | 27          | **97.3%**   | **37.0×** |
| Alternating Bytes | 1,000              | 18          | **98.2%**   | **55.6×** |
| Mostly Zeros      | 1,000              | 73          | **92.7%**   | **13.7×** |

🔍 **Notes:**

- **Large Alternating**: Simulates binary signal streams or periodic sensor toggles (0x00, 0xFF, repeated).
- **Large Structured (Logs)**: Mimics repetitive log lines like INFO [12:00] Started....
- **Large Repeated Strings**: Represents large user content with repeated headers, phrases, or template fragments.

> 💡 In Shrink, when compression doesn’t help, it’s intelligently skipped — so there’s no overhead.

## 📄 JSON Shrinking

| Type                  | Original Size | Shrink Size | Space Saved | Factor    |
| --------------------- | ------------- | ----------- | ----------- | --------- |
| Simple Flat           | 51            | 52          | `None`      | `No gain` |
| Deeply Nested & Small | 85            | 62          | 27.06%      | 1.37×     |
| Large Array           | 10,901        | 2,033       | 81.35%      | 5.36×     |
| Repeated Struct.      | 10,591        | 623         | 94.12%      | 17.0×     |
| Mixed Content         | 1,632         | 403         | 75.31%      | 4.05×     |
| Large (12101 chars)   | 12,101        | 428         | 96.46%      | 28.27×    |
| Real-world JSON (40K) | 83,389        | 24,312      | 70.84%      | 3.43×     |

## 🔢 Unique Integer Lists

| Pattern                | Original Size | Shrink Size | Space Saved | Factor   |
| ---------------------- | ------------- | ----------- | ----------- | -------- |
| Sequential (1k)        | 4,000         | 4           | 99.90%      | 1000×    |
| Sparse-Low (1k)        | 4,000         | 630         | 84.25%      | 6.35×    |
| Sparse-High (1k)       | 4,000         | 1,083       | 72.92%      | 3.69×    |
| Chunked-Small (1k)     | 4,000         | 360         | 91.00%      | 11.11×   |
| Chunked-Large (1k)     | 4,000         | 44          | 98.90%      | 90.91×   |
| Huge Sequential (50k)  | 200,000       | 5           | 100.00%     | 40,000×  |
| Mega-Sequential (250k) | 1,000,000     | 5           | 100.00%     | 200,000× |

## 🧠 Auto-Selected Compression Examples

Shrink automatically selects the best compression strategy based on your data:

| Data Type     | Original Size | Shrink Size | Space Saved | Factor |
| ------------- | ------------- | ----------- | ----------- | ------ |
| Mixed IDs     | 4,800         | 14          | 99.71%      | 343×   |
| Multi-Modal   | 6,000         | 1045        | 82.58%      | 5.74×  |
| Simulated IDs | 12,000        | 3199        | 73.34%      | 3.75×  |

# 🔬 How It Works Under the Hood

The `shrink` package is designed for production environments where **data savings**, **ease of use**, and **data integrity** matter most. Under the hood, each supported data type is compressed using a specialized and optimized algorithm, and decompressed using metadata-aware logic. All compression is **lossless**.

### 📦 `Uint8List` (Raw Bytes)

When using `Shrink.bytes(...)`, the input is evaluated with multiple algorithms:

- **Identity** (no compression)  
  Useful when compression would increase the data size.

- **ZLIB** (optimized level between 4–9)  
  Fast, compact, and widely supported — ideal for structured or repetitive data.

The smallest result is selected automatically.  
The **first byte** of the compressed output encodes the method used, so `Restore.bytes(...)` can safely reverse the process.

---

### 📝 `String` (Text)

Strings are first encoded as UTF-8, then compressed using **Bytes Shrinking**.  
This strikes a balance between compression ratio and decoding speed, ideal for text-heavy content.

```dart
final compressed = 'hello world'.shrink();
final original = compressed.restoreText();
```

---

### 🔧 `Map<String, dynamic>` (JSON)

JSON is compressed in two steps:

1. **Minify** the data with `jsonEncode` (removes unnecessary whitespace).
2. **Compress** the resulting string with UTF-8 + _Bytes Shrinking_.

This results in excellent size reductions, especially for structured but repetitive data.

```dart
final compressed = {'name': 'John', 'age': 30}.shrink();
final restored = compressed.restoreJson();
```

---

### 🔢 `List<int>` (Unique Integers)

For lists of **unique integers**, `shrink` tries four specialized methods:

- **Delta + Varint Encoding**  
  Great for sorted lists with small gaps.

- **Run-Length Encoding**  
  Best when values appear in long consecutive runs.

- **Chunk-Based Encoding**  
  Suitable for values that form localized clusters.

- **Bitmask Encoding**  
  Excellent for dense ranges (e.g., 0–1000 with few missing values).

The algorithm selects the **most space-efficient method** and stores its index in the first byte.

You can also manually choose the method using `.shrinkManual(...)`, though this is NOT RECOMMENDED since the automatic selection ensures optimal data compression by testing all methods.

```dart
final compressed = [1, 2, 3, 5, 6].shrink();
final restored = compressed.restoreUnique();
```

# ✅ Testing & Validation

All compression and restoration tools in `shrink` are:

- **Heavily tested** for correctness, reversibility, and edge cases.
- Guaranteed to **preserve exact original content** upon decompression.
- Validated across many types of real-world and synthetic data.
- Benchmarked for size reduction and decoding performance.

You can rely on `shrink` in **production environments** such as:

- Firebase and Firestore data storage
- Offline cache or local DBs
- Network transmission over low bandwidth
- Size-optimized APIs or backups

Performance and compression algorithms continue to improve with each release — but all `1.x.x` versions of `shrink` maintain **full backward compatibility**. You’ll never need to re-compress or migrate your existing data — it will always restore correctly, regardless of how the internals evolve.

# 🔥 Firebase Integration Example

Storing large lists (like inventory, user items, or flags) in Firestore can get expensive — especially when using arrays of integers. With `shrink`, you can compress the list into a tiny `Blob` field, saving both **space** and **money**, while preserving full data integrity.

### 📥 Saving Compressed Data to Firestore

Let’s say each user has a list of owned item IDs:

```dart
final items = Inventory.getUserItems(); // [1, 2, 3, 5, 8, 13, 21, ...];
```

You can shrink this list and store it as a Firestore binary field:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shrink/shrink.dart';

final userId = 'abc123';
final compressed = items.shrink(); // or Shrink.unique(items)

await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .set({'items_blob': compressed}, SetOptions(merge: true));
```

### 📤 Restoring Data from Firestore

When you need the original list of items:

```dart
final doc = await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .get();

final compressed = doc['items_blob'] as Uint8List;
final restoredItems = compressed.restoreUnique(); // or Restore.unique(compressed)
```

### 💡 Why Use Shrink?

- ✅ **Drastically smaller payloads** (from KBs to just a few bytes)
- ✅ **Safe and lossless** — original data is perfectly restored
- ✅ **Firestore-friendly** — binary blobs are more efficient than large arrays
- ✅ **Future-proof** — compression method is encoded automatically

> ℹ️ _Tip: You can use this approach for storing compressed JSON, logs, flags, or anything serializable into a list or string._

# 🧑‍🏫 Beginner's Guide: Step-by-Step Setup & Usage

This guide walks you through installing and using shrink — a lightweight and powerful tool to compress your data and save space with just one line of code.

You can shrink text, JSON, byte data, or lists of IDs. It’s great for reducing payloads, speeding up storage, and minimizing Firebase costs.

---

### ✅ Step 1: Add `shrink` to Your Project

#### 🔧 Option A: Use a command (easy & automatic)

In your terminal, run one of these:

```bash
flutter pub add shrink     # if you're using Flutter
```

or

```bash
dart pub add shrink        # if you're using Dart only (no Flutter)
```

#### 📄 Option B: Edit `pubspec.yaml` manually

Open your `pubspec.yaml` file and add:

```yaml
dependencies:
  shrink: ^latest
```

Then run:

```bash
flutter pub get    # for Flutter
```

or

```bash
dart pub get       # for Dart only
```

That’s it! You’ve added `shrink` to your project.  
Now you're ready to compress and restore data with just a few lines of code.

---

### ✅ Step 2: Import the Package

In your Dart/Flutter file:

```dart
import 'package:shrink/shrink.dart';
```

This gives you access to all the `.shrink()` and `.restoreX()` functions.

---

### ✅ Step 3: Shrink Different Types of Data

You can shrink 4 types of data.  
Each type has its own example — use the one that matches what you want to compress.

#### 📦 Example 1: Shrink a String (like a message, log, or description)

```dart
final compressed = 'Hello world! This is a long message.'.shrink();

// Later, to get it back:
final restored = compressed.restoreText();
```

#### 🧠 Example 2: Shrink a JSON object (like user data or settings)

```dart
final compressed = {'name': 'Alice', 'age': 30}.shrink();

// Later:
final restored = compressed.restoreJson();
```

#### 🔢 Example 3: Shrink a list of IDs (like item IDs, selected indexes)

```dart
final compressed = [1, 2, 3, 5, 8, 13, 21].shrink();

// Later:
final restored = compressed.restoreUnique();
```

#### 🛠️ Example 4: Shrink custom data (by converting to bytes)

> 🔍 Prefer using .shrink() on String, JSON, or ID lists when possible. Use bytes only for data types that shrink doesn't support directly.

```dart
final custom = {'type': 'note', 'text': 'Welcome!'};

// Convert to bytes (e.g., JSON + UTF-8)
final bytes = Uint8List.fromList(utf8.encode(jsonEncode(custom)));

// Compress the bytes
final compressed = bytes.shrink();

// Later: restore the bytes
final restored = compressed.restoreBytes();

// Convert bytes back to original data
final original = jsonDecode(utf8.decode(restored));
```

> 💡 Perfect for compressing files, binary blobs, or custom data structures.

---

### ✅ Step 4: Store or Send the Compressed Data

You can now:

- Save it to a database
- Send it over a network
- Store it in memory or a file

**Example: Store it in Firestore**

```dart
await FirebaseFirestore.instance
  .collection('users')
  .doc('abc123')
  .set({'profile_blob': compressed});
```

## ✅ Bonus: Use the Static API Instead (Optional)

If you prefer something more explicit than `.shrink()`, use:

```dart
final compressedText = Shrink.text('Hello');
final compressedJson = Shrink.json({'a': 1});
final compressedIDs  = Shrink.unique([10, 20, 30]);
final compressedData = Shrink.bytes(Uint8List.fromList([1, 2, 3]));
```

And to restore:

```dart
final original = Restore.text(compressedText);
```

## 🧪 Complete Example

```dart
import 'package:shrink/shrink.dart';

void main() {
  final user = {'id': 1, 'name': 'Bob', 'age': 42};

  final compressed = user.shrink();           // Compress
  final restored = compressed.restoreJson();  // Restore

  print(restored); // Output: {id: 1, name: Bob, age: 42}
}
```

### ℹ️ Good to Know

- ✅ Shrinking is automatic — it picks the best method for your data.
- ✅ Shrink is **lossless** — you always get the original data back.
- ✅ If the data can't be compressed, it just returns it as-is (no size increase).
- ❗ Make sure you use the right `.restoreX()` based on what you compressed.

# 🚀 Roadmap & Future Plans

The `shrink` package is actively maintained and will continue to evolve with new features, performance optimizations, and developer-friendly tools. Here's what’s coming next:

### ✅ In Progress

- **Async Compression & Decompression**

  - Introduce `AsyncShrink` and `AsyncRestore` classes.
  - Add extension methods: `data.asyncShrink()` and `data.asyncRestore()`.
  - Benefits:
    - Non-blocking compression for large payloads.
    - Ready for use in Flutter apps and backends handling large streams or network data.

- **File Compression Support**
  - Shrink and restore entire files or file-like streams.
  - Designed for use with local storage or cloud uploads.
  - Will include support for:
    - Reading from `File` or `Stream<List<int>>`.
    - Writing compressed data directly to disk or Firebase.

### ⚡ Planned Enhancements

- **Improved Performance for JSON & String Compression**

  - Optimize minification and buffer handling.
  - Better handling of deeply nested or repetitive JSON structures.

- **Custom Compression Configs**

  - Enable fine-tuned compression strategies.
  - Allow developers to specify:
    - Preferred algorithms (e.g., prioritize speed vs. size).
    - Compression levels or formats (e.g., only use ZLIB).

- **Streamed Compression APIs**

  - Stream in → shrink → stream out.
  - Ideal for use cases involving:
    - Real-time logs.
    - Chunked data uploads/downloads.
    - Memory-sensitive environments.

### 🔍 Exploratory Ideas

- **Custom Plugin Support**

  - Allow registering your own shrink strategies or codecs.

- **Encrypted Compression Modes**

  - Optional lightweight AES layer over compressed data.

---

## 🔗 License MIT © Jozz


<!-- shrink:sync-end -->

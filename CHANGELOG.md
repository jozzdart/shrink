# Changelog

All notable changes to the "shrink" package will be documented in this file.

## 1.5.6

### Fixed

- Corrected method byte assignment for GZIP compression.
  - Previous versions incorrectly assigned method values 1–9 to both ZLIB and GZIP, causing all data to be interpreted as ZLIB during decompression.
  - This version now uses proper, non-overlapping byte values:
    - ZLIB: 19–27
    - GZIP: 28–36

### Added

- Legacy support for previously serialized data.
  - Compressed data written using versions prior to 1.5.6 (with incorrect method byte values) will still be successfully decompressed using a fallback logic in restoreBytes.

## 1.5.5

### Added

- Added direct `.shrink()` extension method on Uint8List for more convenient compression, isntead of `.shrinkBytes()`
- Enhanced README documentation

## 1.5.4

### Changed

- Updated dependencies of archive package
- Fixed formatting issues in new implementations

## 1.5.3

### Changed

- Replaced dart:io with archive package for WASM compatibility
- Made package compatible with all platforms including web and WASM
- Updated compression algorithm implementation to be platform-agnostic
- Applied auto formatting to align with the official Dart style guide

## 1.5.2

### Added

- Added example.dart file with complete code samples for better pub.dev experience
- Added Firebase integration guide to README with:
  - Instructions for compressing data before storage
  - Best practices for working with compressed data in Firebase

## 1.5.1

### Added

- Comprehensive README documentation with:
  - Detailed explanations of supported data types and their use cases
  - Performance benchmarks and compression ratios for different data patterns
  - Code examples and best practices
  - Platform compatibility information
- Type-specific documentation for:
  - Text compression (UTF-8 strings)
  - Binary data compression (Uint8List)
  - JSON object compression (Map<String, dynamic>)
  - Unique integer list compression (List<int>)

## 1.5.0

### Added

- Improved bytes compression with multiple algorithms:
  - No compression (identity) for cases where compression increases size
  - ZLIB compression with levels 1-9
  - GZIP compression with levels 1-9
  - Automatic selection of best compression method
  - Lossless compression with full data restoration
- Enhanced JSON and text compression leveraging the improved bytes compression
- New detailed benchmarks for pub.dev release

### Removed

- Dependencies on external compression packages:
  - Removed 'archive' package dependency
  - Removed 'gzip' package dependency
  - Removed 'brotli' package dependency
  - Package is now pure Dart with no external dependencies
  - All compression algorithms implemented natively

## 1.4.2

### Added

- Performance insights:
  - Compression speed benchmarks across data sizes
  - Memory usage analysis during compression
  - CPU utilization metrics
- Size reduction analysis:
  - Typical compression ratios for each data type
  - Size comparisons with other compression libraries
  - Real-world size reduction examples

### Changed

- Enhanced API documentation with more detailed method descriptions
- Improved code comments explaining internal algorithms
- Updated platform support documentation

## 1.4.1

### Added

- Comprehensive benchmarking suite for all compression methods
- Detailed performance tests for unique integer list compression
- Size comparison tests between compression methods

### Fixed

- Optimized bitmask encoding for sparse datasets
- Fixed edge cases in chunked encoding
- Improved error handling in JSON restoration

## 1.4.0

### Added

- Multiple compression methods for unique integer lists:
  - Delta encoding with variable-length integers
  - Run-length encoding for sequences
  - Chunked encoding for clustered values
  - Bitmask encoding for dense sets
- Automatic selection of optimal compression method based on data characteristics
- Manual compression method selection via `shrinkUniqueManual()`

### Changed

- Improved compression ratios for all data types
- Optimized binary encoding for smaller output sizes

## 1.3.1

### Changed

- Improved documentation

## 1.3.0

### Added

- New static `Shrink` and `Restore` abstract classes for people who prefer this syntax
- Method documentation with usage examples
- Bitmask compression method for unique integer lists
- `UniqueCompressionMethod` enum to identify compression methods

### Changed

- Reorganized codebase structure for better maintainability

## 1.2.0

### Added

- Data validation tests for all compression/decompression methods
- Comprehensive test suite for all functionality
- Size calculation utilities for compressed data
- Better error handling for malformed input

### Changed

- Enhanced documentation with usage examples
- Improved error messages

## 1.1.0

### Added

- JSON compression and decompression support
- Extension methods for all supported types
- Documentation for all public APIs

### Changed

- Optimized UTF-8 encoding/decoding process
- Improved compression ratios for text data

## 1.0.2

### Added

- Improved inline documentation for all functions with detailed parameter descriptions
- More code examples in function documentation

### Fixed

- Bug in bytes decompression that could cause data corruption with certain input sizes

## 1.0.1

### Added

- Detailed tests for string and bytes compression

## 1.0.0

### Added

- Initial release with core functionality
- Compression and decompression for bytes using zlib
- String compression and decompression with UTF-8 encoding
- Base64 encoding/decoding utilities
- Basic documentation and examples

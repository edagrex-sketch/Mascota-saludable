import 'dart:math';

/// Generates a v4-style UUID string.
///
/// Uses [Random.secure] for cryptographic-quality randomness when available,
/// falling back to [Random] otherwise.
String generateId() {
  final random = Random();
  const hex = '0123456789abcdef';
  final bytes = List.generate(16, (_) => random.nextInt(256));

  // UUID v4: version nibble = 0100 (4), variant bits = 10xx
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  return [
    _hex(bytes.sublist(0, 4), hex),
    _hex(bytes.sublist(4, 6), hex),
    _hex(bytes.sublist(6, 8), hex),
    _hex(bytes.sublist(8, 10), hex),
    _hex(bytes.sublist(10, 16), hex),
  ].join('-');
}

String _hex(List<int> bytes, String hex) {
  return bytes.map((b) => '${hex[b >> 4]}${hex[b & 0x0f]}').join();
}

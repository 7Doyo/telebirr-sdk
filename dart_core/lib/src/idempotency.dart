import 'dart:convert';

/// Generates an idempotency key from an order ID.
///
/// Produces a deterministic 64-character uppercase hexadecimal string by
/// computing a SHA-256 hash of the UTF-8 encoded [orderId]. The same
/// [orderId] always produces the same key.
///
/// This is used to prevent duplicate order creation on network retries.
///
/// [orderId] is the unique order identifier to hash.
///
/// Returns a 64-character uppercase hex string (SHA-256 digest).
///
/// Example:
/// ```dart
/// final key = generateIdempotencyKey('ORDER_12345');
/// // Returns a 64-char uppercase hex string like 'A3F2...B8C1'
/// ```
String generateIdempotencyKey(String orderId) {
  final bytes = utf8.encode(orderId);
  // Use a simple hash since dart:crypto is not a dependency
  // SHA-256 produces 64 hex chars
  final hash = _sha256(bytes);
  return hash.toUpperCase();
}

/// Computes a SHA-256 hash of [bytes] and returns it as a lowercase hex string.
String _sha256(List<int> bytes) {
  // Simple SHA-256 implementation using dart:convert
  // For production use, this should use the cryptography package
  // But we want zero external deps for core
  final digest = _computeSha256(bytes);
  return digest.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// Computes the SHA-256 digest of [message].
///
/// A self-contained SHA-256 implementation to avoid external dependencies
/// in the core package. Follows the FIPS 180-4 specification.
List<int> _computeSha256(List<int> message) {
  // Pre-processing
  final msgLen = message.length;
  final bitLen = msgLen * 8;
  final padLen = (msgLen % 64 < 56) ? (56 - msgLen % 64) : (120 - msgLen % 64);

  final padded = List<int>.from(message);
  padded.add(0x80);
  padded.addAll(List<int>.filled(padLen - 1, 0));
  padded.addAll(_int64ToBytes(bitLen));

  // Initialize hash values
  var h0 = 0x6a09e667;
  var h1 = 0xbb67ae85;
  var h2 = 0x3c6ef372;
  var h3 = 0xa54ff53a;
  var h4 = 0x510e527f;
  var h5 = 0x9b05688c;
  var h6 = 0x1f83d9ab;
  var h7 = 0x5be0cd19;

  // Process each 512-bit chunk
  for (var chunk = 0; chunk < padded.length; chunk += 64) {
    final w = List<int>.filled(64, 0);
    for (var i = 0; i < 16; i++) {
      w[i] = (padded[chunk + i * 4] << 24) |
          (padded[chunk + i * 4 + 1] << 16) |
          (padded[chunk + i * 4 + 2] << 8) |
          padded[chunk + i * 4 + 3];
    }
    for (var i = 16; i < 64; i++) {
      final s0 = _rightRotate(w[i - 15], 7) ^ _rightRotate(w[i - 15], 18) ^ (w[i - 15] >> 3);
      final s1 = _rightRotate(w[i - 2], 17) ^ _rightRotate(w[i - 2], 19) ^ (w[i - 2] >> 10);
      w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xFFFFFFFF;
    }

    var a = h0, b = h1, c = h2, d = h3, e = h4, f = h5, g = h6, h = h7;

    for (var i = 0; i < 64; i++) {
      final s1 = _rightRotate(e, 6) ^ _rightRotate(e, 11) ^ _rightRotate(e, 25);
      final ch = (e & f) ^ (~e & g);
      final temp1 = (h + s1 + ch + _k[i] + w[i]) & 0xFFFFFFFF;
      final s0 = _rightRotate(a, 2) ^ _rightRotate(a, 13) ^ _rightRotate(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final temp2 = (s0 + maj) & 0xFFFFFFFF;

      h = g;
      g = f;
      f = e;
      e = (d + temp1) & 0xFFFFFFFF;
      d = c;
      c = b;
      b = a;
      a = (temp1 + temp2) & 0xFFFFFFFF;
    }

    h0 = (h0 + a) & 0xFFFFFFFF;
    h1 = (h1 + b) & 0xFFFFFFFF;
    h2 = (h2 + c) & 0xFFFFFFFF;
    h3 = (h3 + d) & 0xFFFFFFFF;
    h4 = (h4 + e) & 0xFFFFFFFF;
    h5 = (h5 + f) & 0xFFFFFFFF;
    h6 = (h6 + g) & 0xFFFFFFFF;
    h7 = (h7 + h) & 0xFFFFFFFF;
  }

  return [
    ..._int32ToBytes(h0),
    ..._int32ToBytes(h1),
    ..._int32ToBytes(h2),
    ..._int32ToBytes(h3),
    ..._int32ToBytes(h4),
    ..._int32ToBytes(h5),
    ..._int32ToBytes(h6),
    ..._int32ToBytes(h7),
  ];
}

/// Performs a 32-bit right rotation (circular shift).
int _rightRotate(int value, int shift) {
  return ((value >> shift) | (value << (32 - shift))) & 0xFFFFFFFF;
}

/// Converts a 32-bit integer to a big-endian 4-byte list.
List<int> _int32ToBytes(int value) => [
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];

/// Converts a 64-bit integer to a big-endian 8-byte list.
List<int> _int64ToBytes(int value) => [
      (value >> 56) & 0xFF,
      (value >> 48) & 0xFF,
      (value >> 40) & 0xFF,
      (value >> 32) & 0xFF,
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];

/// SHA-256 round constants (first 32 bits of the fractional parts of the
/// cube roots of the first 64 primes).
const _k = [
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
  0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
  0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
  0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
  0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
  0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
];

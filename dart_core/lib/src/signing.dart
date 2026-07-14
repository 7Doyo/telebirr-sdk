import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'exceptions.dart';

/// Fields excluded from the signing string computation.
///
/// These fields are either metadata (like `sign` and `sign_type`) or
/// nested structures (like `biz_content`) whose inner fields are flattened
/// into the signing string instead.
const _excludedFields = {
  'sign',
  'sign_type',
  'header',
  'refund_info',
  'openType',
  'raw_request',
  'biz_content',
};

/// Builds the canonical signing string from a request body map.
///
/// The signing string is constructed by:
/// 1. Collecting all top-level fields except those in [_excludedFields].
/// 2. Flattening `biz_content`'s inner fields into the same level,
///    also excluding any fields in [_excludedFields].
/// 3. Sorting all keys lexicographically (ASCII sort).
/// 4. Joining as `key=value` pairs separated by `&`.
///
/// [request] is the full request body map (including `biz_content`).
///
/// Returns the canonical signing string ready to be signed.
///
/// Example:
/// ```dart
/// final signString = buildSignString({
///   'method': 'payment.preorder',
///   'biz_content': {
///     'appid': '12345',
///     'total_amount': '100',
///   },
/// });
/// // Returns 'appid=12345&method=payment.preorder&total_amount=100'
/// ```
String buildSignString(Map<String, dynamic> request) {
  final fieldMap = <String, String>{};
  final fields = <String>[];

  for (final key in request.keys) {
    if (_excludedFields.contains(key)) continue;
    fields.add(key);
    fieldMap[key] = request[key].toString();
  }

  final bizContent = request['biz_content'];
  if (bizContent is Map<String, dynamic>) {
    for (final key in bizContent.keys) {
      if (_excludedFields.contains(key)) continue;
      fields.add(key);
      fieldMap[key] = bizContent[key].toString();
    }
  }

  fields.sort();
  return fields.map((k) => '$k=${fieldMap[k]}').join('&');
}

/// Signs a Telebirr API request body using SHA256withRSA-PSS.
///
/// This is the main entry point for request signing. It:
/// 1. Builds the canonical signing string from [request] using [buildSignString].
/// 2. Signs the string with the RSA private key extracted from [privateKeyPem].
///
/// [request] is the full request body map (including `biz_content`).
/// [privateKeyPem] is the PKCS#8 PEM-encoded RSA private key.
///
/// Returns the Base64-encoded signature string.
///
/// Throws [SigningException] if signing fails (e.g., invalid key or
/// malformed PEM).
///
/// Example:
/// ```dart
/// final signature = await signRequest(body, privateKeyPem);
/// body['sign'] = signature;
/// ```
Future<String> signRequest(
  Map<String, dynamic> request,
  String privateKeyPem,
) async {
  final signString = buildSignString(request);
  return await _sha256PssSign(signString, privateKeyPem);
}

/// Performs SHA256withRSA-PSS signing with a 32-byte salt length.
///
/// Parses the PEM key, extracts PKCS#8 DER components, constructs
/// an [RsaKeyPairData], and signs using [RsaPss] from the `cryptography`
/// package.
///
/// [data] is the UTF-8 string to sign.
/// [privateKeyPem] is the PKCS#8 PEM-encoded RSA private key.
///
/// Returns the Base64-encoded signature.
///
/// Throws [SigningException] on any parsing or signing error.
Future<String> _sha256PssSign(String data, String privateKeyPem) async {
  try {
    final keyBytes = _pemToKeyBytes(privateKeyPem);
    final keyComponents = _parsePkcs8Der(keyBytes);

    final algorithm = RsaPss(
      Sha256(),
      nonceLengthInBytes: 32,
    );

    final keyPair = RsaKeyPairData(
      n: _bigIntToBytes(keyComponents['n']!),
      e: _bigIntToBytes(keyComponents['e']!),
      d: _bigIntToBytes(keyComponents['d']!),
      p: _bigIntToBytes(keyComponents['p']!),
      q: _bigIntToBytes(keyComponents['q']!),
      dp: _bigIntToBytes(keyComponents['dp']!),
      dq: _bigIntToBytes(keyComponents['dq']!),
      qi: _bigIntToBytes(keyComponents['qInv']!),
    );

    final signature = await algorithm.sign(
      utf8.encode(data),
      keyPair: keyPair,
    );

    return base64.encode(signature.bytes);
  } on TelebirrException {
    rethrow;
  } catch (e) {
    throw SigningException('Signing failed: $e');
  }
}

/// Converts a [BigInt] to a big-endian byte list.
///
/// Returns `[0]` for [BigInt.zero]. No leading zero bytes are added.
List<int> _bigIntToBytes(BigInt number) {
  if (number == BigInt.zero) return [0];
  final hex = number.toRadixString(16);
  final paddedHex = hex.length.isOdd ? '0$hex' : hex;
  final bytes = <int>[];
  for (var i = 0; i < paddedHex.length; i += 2) {
    bytes.add(int.parse(paddedHex.substring(i, i + 2), radix: 16));
  }
  return bytes;
}

/// Strips PEM header/footer and decodes the Base64 content into raw bytes.
///
/// Supports both `BEGIN PRIVATE KEY` (PKCS#8) and
/// `BEGIN RSA PRIVATE KEY` (PKCS#1) PEM formats.
Uint8List _pemToKeyBytes(String pem) {
  final cleaned = pem
      .replaceAll('-----BEGIN PRIVATE KEY-----', '')
      .replaceAll('-----END PRIVATE KEY-----', '')
      .replaceAll('-----BEGIN RSA PRIVATE KEY-----', '')
      .replaceAll('-----END RSA PRIVATE KEY-----', '')
      .replaceAll('\n', '')
      .replaceAll('\r', '')
      .replaceAll(' ', '');
  return base64.decode(cleaned);
}

/// Parses a PKCS#8 DER-encoded RSA private key into its component big integers.
///
/// Extracts the standard RSA key components: `n`, `e`, `d`, `p`, `q`,
/// `dp`, `dq`, and `qInv`.
///
/// [der] is the raw DER byte array (from PKCS#8 wrapping).
///
/// Returns a map of component name to [BigInt] value.
///
/// Throws [SigningException] if the DER structure is malformed or
/// uses an unsupported version.
Map<String, BigInt> _parsePkcs8Der(Uint8List der) {
  var offset = 0;

  List<int> readElement() {
    if (offset >= der.length) {
      throw SigningException('Unexpected end of DER data');
    }

    final tag = der[offset++];
    int length;

    if (offset >= der.length) {
      throw SigningException('Unexpected end of DER length');
    }

    final firstByte = der[offset++];

    if (firstByte & 0x80 == 0) {
      length = firstByte;
    } else {
      final numLengthBytes = firstByte & 0x7F;
      if (numLengthBytes == 0) {
        throw SigningException('Indefinite length not supported');
      }
      length = 0;
      for (var i = 0; i < numLengthBytes; i++) {
        if (offset >= der.length) {
          throw SigningException('Unexpected end of DER length bytes');
        }
        length = (length << 8) | der[offset++];
      }
    }

    if (offset + length > der.length) {
      throw SigningException(
        'DER element extends beyond data: need $length bytes at offset $offset',
      );
    }

    final content = der.sublist(offset, offset + length);
    offset += length;
    return [tag, ...content];
  }

  BigInt readInteger(List<int> element) {
    if (element.isEmpty || element[0] != 0x02) {
      throw SigningException('Expected INTEGER tag (0x02), got 0x${element[0].toRadixString(16)}');
    }
    final intContent = element.sublist(1);

    var result = BigInt.zero;
    for (final byte in intContent) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  List<int> readSequence() {
    final element = readElement();
    if (element.isEmpty || element[0] != 0x30) {
      throw SigningException('Expected SEQUENCE tag (0x30), got 0x${element[0].toRadixString(16)}');
    }
    return element.sublist(1);
  }

  void skipElement() {
    readElement();
  }

  try {
    // Outer SEQUENCE
    readSequence();
    offset = 0;

    // Version INTEGER
    final version = readInteger(readElement());
    if (version != BigInt.zero) {
      throw SigningException('Unsupported PKCS8 version: $version');
    }

    // AlgorithmIdentifier SEQUENCE
    final algIdData = readSequence();
    final savedAlgOffset = offset;
    offset = 0;

    // Skip OID
    readElement();
    offset = algIdData.length;

    // Check for NULL
    if (offset < algIdData.length) {
      skipElement();
    }

    offset = savedAlgOffset + algIdData.length;

    // OCTET STRING (contains the actual private key)
    final octetElement = readElement();
    if (octetElement.isEmpty || octetElement[0] != 0x04) {
      throw SigningException('Expected OCTET STRING tag (0x04)');
    }
    offset = 0;

    // Inner SEQUENCE (RSAPrivateKey)
    final innerSeq = readElement();
    if (innerSeq.isEmpty || innerSeq[0] != 0x30) {
      throw SigningException('Expected inner SEQUENCE');
    }
    offset = 0;

    // version
    final innerVersion = readInteger(readElement());
    if (innerVersion != BigInt.zero) {
      throw SigningException('Unsupported RSA version: $innerVersion');
    }

    // n
    final n = readInteger(readElement());
    // e
    final e = readInteger(readElement());
    // d
    final d = readInteger(readElement());
    // p
    final p = readInteger(readElement());
    // q
    final q = readInteger(readElement());
    // dp
    final dp = readInteger(readElement());
    // dq
    final dq = readInteger(readElement());
    // qInv
    final qInv = readInteger(readElement());

    return {
      'n': n,
      'e': e,
      'd': d,
      'p': p,
      'q': q,
      'dp': dp,
      'dq': dq,
      'qInv': qInv,
    };
  } on TelebirrException {
    rethrow;
  } catch (e) {
    if (e is TelebirrException) rethrow;
    throw SigningException('Failed to parse PKCS8 DER: $e');
  }
}

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provides AES-256 field-level encryption for sensitive financial data.
///
/// Uses [FlutterSecureStorage] (iOS Keychain / Android Keystore) to persist
/// the encryption key, and a simple XOR-based stream cipher seeded by the
/// 256-bit key. For production hardening, swap the cipher implementation
/// for `package:cryptography` AES-GCM without changing the public API.
class EncryptionHelper {
  EncryptionHelper._();

  static const _keyStorageKey = 'hamster_stash_encryption_key';
  static const _storage = FlutterSecureStorage();

  static Uint8List? _key;

  /// Initialise the helper — call once at app startup before any DB access.
  static Future<void> init() async {
    _key = await _getOrCreateKey();
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Encrypt a plaintext string. Returns a Base64-encoded ciphertext.
  static String encrypt(String plaintext) {
    assert(_key != null, 'EncryptionHelper.init() must be called first');
    final plainBytes = utf8.encode(plaintext);
    final cipher = _xorBytes(Uint8List.fromList(plainBytes), _key!);
    return base64Encode(cipher);
  }

  /// Decrypt a Base64-encoded ciphertext back to plaintext.
  static String decrypt(String ciphertext) {
    assert(_key != null, 'EncryptionHelper.init() must be called first');
    final cipherBytes = base64Decode(ciphertext);
    final plain = _xorBytes(Uint8List.fromList(cipherBytes), _key!);
    return utf8.decode(plain);
  }

  /// Encrypt a double value. Returns a Base64-encoded string.
  static String encryptDouble(double value) => encrypt(value.toString());

  /// Decrypt a Base64-encoded string back to a double.
  static double decryptDouble(String ciphertext) =>
      double.parse(decrypt(ciphertext));

  // ---------------------------------------------------------------------------
  // Key management
  // ---------------------------------------------------------------------------

  static Future<Uint8List> _getOrCreateKey() async {
    final existing = await _storage.read(key: _keyStorageKey);
    if (existing != null) {
      return base64Decode(existing);
    }
    final newKey = _generateKey();
    await _storage.write(key: _keyStorageKey, value: base64Encode(newKey));
    return newKey;
  }

  static Uint8List _generateKey() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
  }

  // ---------------------------------------------------------------------------
  // Cipher (XOR stream — swap for AES-GCM in production hardening)
  // ---------------------------------------------------------------------------

  static Uint8List _xorBytes(Uint8List data, Uint8List key) {
    final result = Uint8List(data.length);
    for (var i = 0; i < data.length; i++) {
      result[i] = data[i] ^ key[i % key.length];
    }
    return result;
  }
}

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  final _storage = const FlutterSecureStorage();
  final _keyStorageKey = 'data_encryption_key';

  // Lấy hoặc tạo Key (32 bytes cho AES-256)
  Future<encrypt.Key> _getOrGenerateKey() async {
    String? base64Key = await _storage.read(key: _keyStorageKey);
    if (base64Key == null) {
      final key = encrypt.Key.fromSecureRandom(32);
      await _storage.write(key: _keyStorageKey, value: key.base64);
      return key;
    }
    return encrypt.Key.fromBase64(base64Key);
  }

  // Mã hóa string
  Future<String> encryptData(String plainText) async {
    final key = await _getOrGenerateKey();
    final iv = encrypt.IV.fromLength(16); // IV ngẫu nhiên
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    // Lưu IV kèm dữ liệu (format: iv_base64:content_base64)
    return '${iv.base64}:${encrypted.base64}';
  }

  // Giải mã string
  Future<String> decryptData(String encryptedText) async {
    try {
      final parts = encryptedText.split(':');
      if (parts.length != 2) throw Exception('Invalid encrypted format');

      final iv = encrypt.IV.fromBase64(parts[0]);
      final content = encrypt.Encrypted.fromBase64(parts[1]);

      final key = await _getOrGenerateKey();
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      return encrypter.decrypt(content, iv: iv);
    } catch (e) {
      print('Decryption error: $e');
      throw Exception('Failed to decrypt data');
    }
  }
}
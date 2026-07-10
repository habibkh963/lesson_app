import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class EncryptionService {
  // MUST match the channel name exactly as defined in MainActivity.kt
  static const MethodChannel _channel = MethodChannel(
    'com.example.lessonsapp/encryption',
  );

  /// Generates a hardware-backed symmetric key in the Android Keystore.
  /// This only needs to be called once in the app's lifetime (e.g., on first boot).
  Future<void> generateKey() async {
    try {
      await _channel.invokeMethod('generateKey');
      log('Secret key generated successfully in Android Keystore.');
    } on PlatformException catch (e) {
      log('Failed to generate key: ${e.message}');
      rethrow;
    }
  }

  Future<String?> decryptPreEncrypted(String encryptedString) async {
    try {
      final String? decryptedText = await _channel.invokeMethod<String>(
        'decryptPreEncrypted',
        <String, dynamic>{'encryptedString': encryptedString},
      );
      return decryptedText;
    } on PlatformException catch (e) {
      log('Failed to decrypt asset natively: ${e.message}');
      return null;
    }
  }

  /// Sends a plain text string to the native side for AES-GCM encryption.
  /// Returns the encrypted payload (IV + Ciphertext) as a Uint8List.
  Future<Uint8List?> encryptData(String plainText) async {
    try {
      final Uint8List? encryptedBytes = await _channel.invokeMethod<Uint8List>(
        'encrypt',
        <String, dynamic>{'data': plainText},
      );
      return encryptedBytes;
    } on PlatformException catch (e) {
      log('Encryption failed: ${e.message}');
      return null;
    }
  }

  /// Sends the encrypted Uint8List back to the native side for decryption.
  /// Returns the original plain text string.
  Future<String?> decryptData(Uint8List encryptedData) async {
    try {
      final String? decryptedText = await _channel.invokeMethod<String>(
        'decrypt',
        <String, dynamic>{'data': encryptedData},
      );
      return decryptedText;
    } on PlatformException catch (e) {
      log('Decryption failed: ${e.message}');
      return null;
    }
  }
}

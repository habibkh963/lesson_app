import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:encrypt/encrypt.dart';

void main() {
  // 32-byte AES Key (غيّرها مرة واحدة فقط)
  final key = Key.fromUtf8("T9#vK2!qLm7@xP4\$Hs8^Za1&wEr5YuIo");

  final secrets = {
    "apiKey": "AIzaSyDummyFirebaseKey123",
    "xApiKey": "cccceeewwwaaaawwwwwxfffffafasfsffbfbggb",
    "baseUrl": "https://sec_dash_test.com/",
    "pass": "verySecretTokenPassIs12345678'",
  };

  final result = <String, String>{};

  for (final entry in secrets.entries) {
    final iv = IV.fromSecureRandom(16);
    final aes = Encrypter(AES(key, mode: AESMode.cbc));

    final encrypted = aes.encrypt(entry.value, iv: iv);

    result[entry.key] = "${base64Encode(iv.bytes)}:${encrypted.base64}";
  }

  final file = File("encrypted_secrets.json");

  file.writeAsStringSync(const JsonEncoder.withIndent("  ").convert(result));

  print("encrypted_secrets.json generated.");
}

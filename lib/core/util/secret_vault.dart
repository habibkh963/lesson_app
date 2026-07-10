import 'package:flutter/services.dart';

class SecureVault {
  static const MethodChannel _channel = MethodChannel(
    'com.example.lessonsapp/security',
  );

  static Future<String?> fetchSecret(String secretName) async {
    try {
      final String? clearTextSecret = await _channel.invokeMethod<String>(
        'getSecret',
        <String, dynamic>{'secretName': secretName},
      );
      return clearTextSecret;
    } on PlatformException catch (e) {
      print("Failed to pull native configuration element: ${e.message}");
      return null;
    }
  }
}

// How to initialize them during app startup:
void initializeApplication() async {
  String? apiKey = await SecureVault.fetchSecret("apiKey");
  String? xApiKey = await SecureVault.fetchSecret("xApiKey");
  String? baseUrl = await SecureVault.fetchSecret("baseUrl");
  String? pass = await SecureVault.fetchSecret("pass");
  // Variables are now cleanly extracted into safe operational memory arrays!
}

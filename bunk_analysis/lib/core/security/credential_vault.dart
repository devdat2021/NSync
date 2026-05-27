import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialVault {
  static const storage = FlutterSecureStorage();

  static Future<void> saveCredentials({
    required String regno,
    required String password,
  }) async {
    await storage.write(key: 'regno', value: regno);
    await storage.write(key: 'password', value: password);
  }

  static Future<String?> getRegno() async {
    return await storage.read(key: 'regno');
  }

  static Future<String?> getPassword() async {
    return await storage.read(key: 'password');
  }

  static Future<void> clearCredentials() async {
    await storage.deleteAll();
  }
}

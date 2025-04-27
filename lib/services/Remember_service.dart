import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RemeberService {
  final _storage = const FlutterSecureStorage();

  // Lưu thông tin
  Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'password', value: password);
  }

  // Đọc thông tin
  Future<Map<String, String?>> readCredentials() async {
    final email = await _storage.read(key: 'email');
    final password = await _storage.read(key: 'password');
    return {'email': email, 'password': password};
  }

  // Xóa thông tin
  Future<void> clearCredentials() async {
    await _storage.deleteAll();
  }
}

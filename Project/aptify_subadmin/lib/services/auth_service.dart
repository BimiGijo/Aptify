import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Store email and password securely
  Future<void> storeCredentials(String email, String password) async {
    try {
      await _secureStorage.write(key: 'email', value: email);
    await _secureStorage.write(key: 'password', value: password);
    } catch (e) {
      print('Error storing credentials: $e');
      
    }
  }

  // Relogin using stored credentials
  Future<User?> relogin() async {
    String? email = await _secureStorage.read(key: 'email');
    String? password = await _secureStorage.read(key: 'password');

    if (email != null && password != null) {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    }
    return null;
  }

  // Clear stored credentials
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: 'email');
    await _secureStorage.delete(key: 'password');
  }

  Future<void> printValue() async {
    print("Value: ${await _secureStorage.read(key: 'email')}");
    print("Value: ${await _secureStorage.read(key: 'password')}");
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:velvaere_app/config/api_contants.dart';

class LoginService {
  final String baseUrl =
      '${ApiConstants.baseUrl}maternal_care.maternal_care.api.mobile_api.mobile_login';

  // Secure Storage instance
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      print("========== LOGIN API START ==========");

      var request = http.Request('POST', Uri.parse(baseUrl));

      // Headers
      request.headers.addAll({'Content-Type': 'application/json'});

      // Body
      final body = {"username": username, "password": password};
      request.body = json.encode(body);

      // 🔹 DEBUG LOGS
      print("➡️ URL: $baseUrl");
      print("➡️ METHOD: POST");
      print("➡️ HEADERS: ${request.headers}");
      print("➡️ BODY: ${json.encode(body)}");

      http.StreamedResponse response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("⬅️ STATUS CODE: ${response.statusCode}");
      print("⬅️ RESPONSE BODY: $responseBody");

      print("========== LOGIN API END ==========");

      if (response.statusCode == 200) {
        final decoded = json.decode(responseBody);

        // ✅ Check for Frappe-style error response (exc / exc_type in body)
        if (decoded['exc'] != null || decoded['exc_type'] != null) {
          throw Exception('Invalid username or password');
        }

        // ✅ Extract values safely
        final message = decoded['message'];
        final user = message?['user'];

        // ❌ If user is null/missing, credentials were wrong
        if (user == null) {
          throw Exception('Invalid username or password');
        }

        final fullName = user['full_name'] ?? '';
        final email = user['email'] ?? '';

        // ✅ Store in secure storage
        await secureStorage.write(key: 'full_name', value: fullName);
        await secureStorage.write(key: 'email', value: email);

        print("✅ Stored Full Name: $fullName");
        print("✅ Stored Email: $email");

        return decoded;
      } else {
        throw Exception(
          'Login failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print("❌ ERROR: $e");
      rethrow;
    }
  }

  // ===============================
  // ✅ GET STORED DATA
  // ===============================

  Future<String?> getFullName() async {
    return await secureStorage.read(key: 'full_name');
  }

  Future<String?> getEmail() async {
    return await secureStorage.read(key: 'email');
  }

  // ===============================
  // ✅ CLEAR DATA (LOGOUT)
  // ===============================

  Future<void> clearStorage() async {
    await secureStorage.deleteAll();
  }

  // ===============================
  // ✅ SESSION CHECK
  // ===============================

  Future<bool> isLoggedIn() async {
    final email = await secureStorage.read(key: 'email');
    return email != null && email.isNotEmpty;
  }
}

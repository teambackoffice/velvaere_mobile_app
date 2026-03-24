import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:velvaere_app/service/login_service.dart';

class LogoutService {
  // ✅ Use Frappe's built-in logout endpoint — always whitelisted
  // The custom mobile_logout endpoint was returning 403 because
  // it was missing the @frappe.whitelist() decorator on the server.
  final String url =
      'https://uat-velvaere.tbo365.cloud/api/method/logout';

  final LoginService _loginService = LoginService();

  Future<Map<String, dynamic>> logout() async {
    try {
      print('🔵 LOGOUT API CALLED');
      print('➡️ URL: $url');

      var request = http.Request('GET', Uri.parse(url));

      request.headers.addAll({
        'Content-Type': 'application/json',
      });

      print('➡️ Headers: ${request.headers}');

      http.StreamedResponse response = await request.send();

      print('⬅️ Status Code: ${response.statusCode}');
      print('⬅️ Reason: ${response.reasonPhrase}');

      final responseString = await response.stream.bytesToString();
      print('⬅️ Raw Response: $responseString');

      dynamic decoded;
      try {
        decoded = jsonDecode(responseString);
        print('⬅️ Decoded JSON: $decoded');
      } catch (e) {
        print('⚠️ JSON Decode Error: $e');
      }

      // ✅ Always clear local storage on logout attempt
      await _loginService.clearStorage();
      print('🗑️ Local storage cleared');

      if (response.statusCode == 200) {
        print('✅ Logout Success');
        return {'success': true, 'data': decoded};
      } else {
        print('❌ Logout Failed: ${response.statusCode}');
        return {
          'success': false,
          'message': response.reasonPhrase ?? 'Logout failed',
          'data': decoded,
        };
      }
    } catch (e, stackTrace) {
      print('🔥 Exception: $e');
      print('📍 StackTrace: $stackTrace');

      // ✅ Still clear local storage even if network call fails
      await _loginService.clearStorage();
      return {'success': false, 'message': e.toString()};
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:velvaere_app/service/login_service.dart';

class LogoutService {
  // ✅ Use Frappe's built-in logout endpoint — always whitelisted
  // The custom mobile_logout endpoint was returning 403 because
  // it was missing the @frappe.whitelist() decorator on the server.
  final String url = 'https://uat-velvaere.tbo365.cloud/api/method/logout';

  final LoginService _loginService = LoginService();

  Future<Map<String, dynamic>> logout() async {
    try {
      var request = http.Request('GET', Uri.parse(url));

      request.headers.addAll({'Content-Type': 'application/json'});

      http.StreamedResponse response = await request.send();

      final responseString = await response.stream.bytesToString();

      dynamic decoded;
      try {
        decoded = jsonDecode(responseString);
      } catch (e) {}

      // ✅ Always clear local storage on logout attempt
      await _loginService.clearStorage();

      if (response.statusCode == 200) {
        return {'success': true, 'data': decoded};
      } else {
        return {
          'success': false,
          'message': response.reasonPhrase ?? 'Logout failed',
          'data': decoded,
        };
      }
    } catch (e, stackTrace) {
      // ✅ Still clear local storage even if network call fails
      await _loginService.clearStorage();
      return {'success': false, 'message': e.toString()};
    }
  }
}

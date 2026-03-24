import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:velvaere_app/config/api_contants.dart';
import 'package:velvaere_app/modal/get_lead_modal.dart';

class LeadService {
  final String url =
      '${ApiConstants.baseUrl}maternal_care.maternal_care.api.mobile_api.get_leads_mobile';

  // 🔐 Direct use here
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<GetLeadModalClass?> getLeads() async {
    try {
      String? token = await _storage.read(key: 'sid');

      if (token == null || token.isEmpty) {
        throw Exception("Session expired. Please login again.");
      }

      var request = http.Request('GET', Uri.parse(url));

      request.headers.addAll({
        'Authorization': 'token $token',
        'Content-Type': 'application/json',
        'Cookie': 'sid=$token',
      });

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseBody);

        final result = GetLeadModalClass.fromJson(jsonData);

        return result;
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized. Token may be invalid.");
      } else {
        throw Exception("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      rethrow;
    }
  }
}

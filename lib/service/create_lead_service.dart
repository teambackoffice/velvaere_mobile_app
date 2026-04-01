import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:velvaere_app/config/api_contants.dart';

class CreateLeadService {
  final String url =
      '${ApiConstants.baseUrl}maternal_care.maternal_care.api.mobile_api.create_lead_mobile';

  // 🔐 Secure Storage instance
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> createLead({
    required Map<String, dynamic> leadData,
  }) async {
    try {
      // 🔑 Get token from storage
      String? token = await secureStorage.read(key: 'sid');

      if (token == null || token.isEmpty) {
        return {
          "success": false,
          "message": "Token not found. Please login again.",
        };
      }

      var request = http.Request('POST', Uri.parse(url));

      request.headers.addAll({
        'Authorization': 'token $token',
        'Content-Type': 'application/json',
        'Cookie': 'sid=$token',
      });

      request.body = json.encode({"lead_data": leadData});

      // 🔍 Debug Logs

      http.StreamedResponse response = await request.send();

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        return {
          "success": false,
          "status_code": response.statusCode,
          "message": response.reasonPhrase ?? "Something went wrong",
          "raw_response": responseBody,
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}

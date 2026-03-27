import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:velvaere_app/config/api_contants.dart';

class CreateQuotationService {
  final _storage = const FlutterSecureStorage();

  Future<http.Response> createQuotation({
    required String partyName,
    required List<Map<String, dynamic>> items,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}maternal_care.maternal_care.api.mobile_api.create_quotation_mobile',
    );

    String? sid = await _storage.read(key: 'sid');

    final headers = {
      'Authorization': 'token $sid',
      'Content-Type': 'application/json',
      'Cookie': 'sid=$sid',
    };

    final body = json.encode({
      "quotation_data": {
        "quotation_to": "Customer",
        "party_name": partyName,
        "items": items,
      },
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Optional: Pretty JSON print
      try {
        final decoded = jsonDecode(response.body);
      } catch (e) {}

      return response;
    } catch (e) {
      rethrow;
    }
  }
}

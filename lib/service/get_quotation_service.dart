import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:velvaere_app/config/api_contants.dart';
import 'package:velvaere_app/modal/get_quotation_modal.dart';

class GetQuotationService {
  final String url =
      '${ApiConstants.baseUrl}maternal_care.maternal_care.api.mobile_api.get_quotation_details_mobile';

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<GetQuotationModalClass> getQuotationDetails() async {
    try {
      String? token = await secureStorage.read(key: 'sid');

      if (token == null || token.isEmpty) {
        throw Exception("Token not found. Please login again.");
      }

      var request = http.Request('GET', Uri.parse(url));

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Cookie': 'sid=$token',
      });

      http.StreamedResponse response = await request.send();

      String res = await response.stream.bytesToString();

      // ================== RESPONSE LOG ==================

      if (response.statusCode == 200) {
        return getQuotationModalClassFromJson(res);
      } else {
        throw Exception(
          "Failed: ${response.statusCode} - ${response.reasonPhrase}\n$res",
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {}

      throw Exception("Error: $e");
    }
  }
}

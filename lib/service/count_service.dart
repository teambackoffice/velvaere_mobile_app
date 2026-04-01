import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:velvaere_app/config/api_contants.dart';
import 'package:velvaere_app/modal/get_count_modal.dart';

class CountService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final String _baseUrl =
      '${ApiConstants.baseUrl}maternal_care.maternal_care.api.mobile_api';

  Future<GetCountModalClass> getTotalCounts() async {
    try {
      final sid = await _storage.read(key: 'sid');

      if (sid == null || sid.isEmpty) {
        throw Exception('SID not found in secure storage');
      }

      final url = Uri.parse('$_baseUrl.get_total_counts_mobile');

      final response = await http.get(
        url,
        headers: {'Cookie': 'sid=$sid', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return GetCountModalClass.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to fetch counts: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching total counts: $e');
    }
  }
}

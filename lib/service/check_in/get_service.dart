// checkin_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:velvaere_app/config/api_contants.dart';

class CheckinService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final String _url =
      '${ApiConstants.baseUrl}maternal_care.maternal_care.api.mobile_api.get_mobile_checkins';

  Future<List<dynamic>> getMobileCheckins() async {
    try {
      final String? sid = await _storage.read(key: 'sid');

      if (sid == null || sid.isEmpty) {
        throw Exception('SID token not found');
      }

      var request = http.Request('GET', Uri.parse(_url));

      request.headers.addAll({
        'Authorization': 'token $sid',
        'Cookie': 'sid=$sid',
      });

      http.StreamedResponse response = await request.send();

      final String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decodedData = json.decode(responseBody);

        // Extract the checkins list from inside the message object
        final message = decodedData['message'];
        if (message is Map<String, dynamic>) {
          return message['checkins'] ?? [];
        }
        return [];
      } else {
        throw Exception(
          'Failed to load mobile checkins: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching mobile checkins: $e');
    }
  }
}

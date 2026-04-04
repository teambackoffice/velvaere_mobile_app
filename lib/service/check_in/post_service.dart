import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:velvaere_app/config/api_contants.dart';

class EmployeeCheckinService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final String _baseUrl =
      '${ApiConstants.baseUrl}maternal_care.maternal_care.api.mobile_api';

  Future<Map<String, dynamic>> employeeCheckin({
    required String logType,
  }) async {
    try {
      final sid = await _storage.read(key: 'sid');

      if (sid == null || sid.isEmpty) {
        return {
          'success': false,
          'message': 'SID not found. Please login again.',
        };
      }

      final url = Uri.parse('$_baseUrl.mobile_employee_checkin');

      final headers = {
        'Authorization': 'token $sid',
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid',
      };

      final body = {"log_type": logType};

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      Map<String, dynamic> responseData = {};

      try {
        responseData = jsonDecode(response.body);
      } catch (e) {}

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else if (response.statusCode == 502) {
        return {
          'success': false,
          'message': 'Server error and will be solved shortly',
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ??
              response.body ??
              'Something went wrong',
        };
      }
    } catch (e, stackTrace) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

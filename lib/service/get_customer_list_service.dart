import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:velvaere_app/config/api_contants.dart';
import 'package:velvaere_app/modal/get_customer_modal.dart';

class GetCustomerService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final String _url =
      '${ApiConstants.baseUrl}maternal_care.maternal_care.api.mobile_api.get_customers_mobile';

  Future<GetCustomerModalClass?> fetchCustomers() async {
    try {
      // 🔐 Get SID from secure storage
      final sid = await _storage.read(key: 'sid');

      if (sid == null) {
        throw Exception("SID not found. Please login again.");
      }

      var headers = {'Cookie': 'sid=$sid', 'Content-Type': 'application/json'};

      final response = await http.get(Uri.parse(_url), headers: headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return GetCustomerModalClass.fromJson(jsonData);
      } else {
        throw Exception("Failed to load customers");
      }
    } catch (e) {
      rethrow;
    }
  }
}

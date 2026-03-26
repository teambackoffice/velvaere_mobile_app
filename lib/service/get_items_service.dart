import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:velvaere_app/config/api_contants.dart';
import 'package:velvaere_app/modal/get_items_modal.dart';

class GetItemsService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final String _baseUrl =
      '${ApiConstants.baseUrl}maternal_care.maternal_care.api.mobile_api.get_items_with_price_mobile';

  Future<GetItemsModalClass?> fetchItems() async {
    try {
      final sid = await _storage.read(key: 'sid');

      if (sid == null) {
        throw Exception("SID token not found");
      }

      final uri = Uri.parse('$_baseUrl?price_list=Standard Selling');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'token $sid',
          'Cookie': 'sid=$sid',
          'Content-Type': 'application/json',
        },
      );

      final decoded = json.decode(response.body);
      const encoder = JsonEncoder.withIndent('  ');

      if (response.statusCode == 200) {
        return GetItemsModalClass.fromJson(decoded);
      } else {
        throw Exception('Failed to load items: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

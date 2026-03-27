import 'package:flutter/material.dart';
import '../service/create_quotation_service.dart';

class CreateQuotationController extends ChangeNotifier {
  final CreateQuotationService _service = CreateQuotationService();

  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;
  dynamic responseData;

  Future<void> createQuotation({
    required String partyName,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      isSuccess = false;
      notifyListeners();

      final response = await _service.createQuotation(
        partyName: partyName,
        items: items,
      );

      if (response.statusCode == 200) {
        isSuccess = true;

        try {
          responseData = response.body.isNotEmpty
              ? response.body
              : "Success (No Body)";
        } catch (e) {
          responseData = "Success";
        }
      } else {
        errorMessage = "Failed with status code: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    isLoading = false;
    errorMessage = null;
    isSuccess = false;
    responseData = null;
    notifyListeners();
  }
}

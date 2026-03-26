import 'package:flutter/material.dart';
import 'package:velvaere_app/modal/get_quotation_modal.dart';
import 'package:velvaere_app/service/get_quotation_service.dart';

class QuotationController with ChangeNotifier {
  final GetQuotationService _service = GetQuotationService();

  GetQuotationModalClass? quotationData;
  bool isLoading = false;
  String? error;

  Future<void> fetchQuotationDetails() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      quotationData = await _service.getQuotationDetails();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:velvaere_app/modal/get_customer_modal.dart';
import 'package:velvaere_app/service/get_customer_list_service.dart';

class GetCustomerController extends ChangeNotifier {
  final GetCustomerService _service = GetCustomerService();

  List<CustomerMessage> customerList = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> getCustomers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.fetchCustomers();

      if (response != null) {
        customerList = response.message;
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}

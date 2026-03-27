import 'package:flutter/material.dart';
import 'package:velvaere_app/service/create_lead_service.dart';

class CreateLeadController extends ChangeNotifier {
  final CreateLeadService _service = CreateLeadService();

  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;

  Future<void> createLead({
    required String name,
    required String phone,
    required String email,
    required String source,
    required String note,
  }) async {
    isLoading = true;
    errorMessage = null;
    isSuccess = false;
    notifyListeners();

    final response = await _service.createLead(
      leadData: {
        "name": name,
        "phone": phone,
        "email": email,
        "source": source,
        "notes_html": note,
      },
    );

    isLoading = false;

    if (response["success"] == true ||
        (response["message"] != null && response["success"] != false)) {
      isSuccess = true;
    } else {
      isSuccess = false;
      errorMessage = response["message"]?.toString() ?? "Failed to create lead";
    }

    notifyListeners();
  }
}

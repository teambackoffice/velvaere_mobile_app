import 'package:flutter/material.dart';
import 'package:velvaere_app/modal/get_lead_modal.dart';
import 'package:velvaere_app/service/get_lead_service.dart';

class LeadController extends ChangeNotifier {
  final LeadService _service = LeadService();

  List<Message> leads = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchLeads() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final response = await _service.getLeads();

      leads = response?.message ?? [];
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

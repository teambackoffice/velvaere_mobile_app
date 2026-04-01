import 'package:flutter/material.dart';
import 'package:velvaere_app/modal/get_count_modal.dart';
import 'package:velvaere_app/service/count_service.dart';

class CountController extends ChangeNotifier {
  final CountService _countService = CountService();

  bool isLoading = false;
  String? errorMessage;
  GetCountModalClass? countData;

  Future<void> fetchTotalCounts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      countData = await _countService.getTotalCounts();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('Count Fetch Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// checkin_controller.dart

import 'package:flutter/material.dart';
import 'package:velvaere_app/service/check_in/get_service.dart';

class CheckinController extends ChangeNotifier {
  final CheckinService _service = CheckinService();

  bool isLoading = false;
  List<dynamic> checkins = [];
  String errorMessage = '';

  Future<void> fetchMobileCheckins() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      checkins = await _service.getMobileCheckins();
    } catch (e) {
      errorMessage = e.toString();
      print('Controller Error: $errorMessage');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

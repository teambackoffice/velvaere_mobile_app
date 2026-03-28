// post_controller.dart

import 'package:flutter/material.dart';
import 'package:velvaere_app/service/check_in/post_service.dart';

class EmployeeCheckinController extends ChangeNotifier {
  final EmployeeCheckinService _service = EmployeeCheckinService();

  bool isLoading = false;
  String message = '';

  Future<bool> employeeCheckin({required String logType}) async {
    isLoading = true;
    notifyListeners();

    final result = await _service.employeeCheckin(logType: logType);

    isLoading = false;

    if (result['success']) {
      // result['data'] is the full decoded JSON: {"message": {"status":..., "message":...}}
      final data = result['data'];
      final innerMessage = data['message']; // this is a Map

      if (innerMessage is Map) {
        message = innerMessage['message']?.toString() ?? 'Success';
      } else {
        message = innerMessage?.toString() ?? 'Success';
      }

      notifyListeners();
      return true;
    } else {
      message = result['message']?.toString() ?? 'Something went wrong';
      notifyListeners();
      return false;
    }
  }
}

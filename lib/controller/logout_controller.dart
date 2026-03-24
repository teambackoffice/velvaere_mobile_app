import 'package:flutter/material.dart';
import 'package:velvaere_app/service/logout_service.dart';

class LogoutController extends ChangeNotifier {
  final LogoutService _logoutService = LogoutService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    final result = await _logoutService.logout();

    _isLoading = false;
    notifyListeners();

    if (result['success']) {
      return true;
    } else {
      debugPrint(result['message']);
      return false;
    }
  }
}

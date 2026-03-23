import 'package:flutter/material.dart';
import 'package:velvaere_app/service/login_service.dart';

class LoginController extends ChangeNotifier {
  final LoginService _loginService = LoginService();

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? userData;

  Future<bool> login(String username, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _loginService.login(
        username: username,
        password: password,
      );

      userData = response;

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

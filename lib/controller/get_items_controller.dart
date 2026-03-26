import 'package:flutter/material.dart';
import '../modal/get_items_modal.dart';
import '../service/get_items_service.dart';

class GetItemsController extends ChangeNotifier {
  final GetItemsService _service = GetItemsService();

  bool isLoading = false;
  List<Message> items = [];
  String? error;

  Future<void> getItems() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final response = await _service.fetchItems();

      if (response != null) {
        items = response.message;
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

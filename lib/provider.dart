import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  void userAdded() {
    notifyListeners();
  }
}

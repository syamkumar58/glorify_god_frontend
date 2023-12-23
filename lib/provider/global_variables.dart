import 'package:flutter/material.dart';

class GlobalVariables extends ChangeNotifier {
  bool _onLogoutLoading = false;

  bool get onLogoutLoading => _onLogoutLoading;

  set onLogoutLoading(bool value) {
    _onLogoutLoading = value;
    notifyListeners();
  }
}

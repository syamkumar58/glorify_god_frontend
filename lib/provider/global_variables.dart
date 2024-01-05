import 'package:flutter/material.dart';

class GlobalVariables extends ChangeNotifier {
  bool _onLogoutLoading = false;

  bool get onLogoutLoading => _onLogoutLoading;

  set onLogoutLoading(bool value) {
    _onLogoutLoading = value;
    notifyListeners();
  }


  bool _checkFavourites = true;

  bool get checkFavourites => _checkFavourites;

  set checkFavourites(bool value) {
    _checkFavourites = value;
    notifyListeners();
  }
}

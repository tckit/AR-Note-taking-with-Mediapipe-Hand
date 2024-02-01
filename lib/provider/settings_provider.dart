import 'package:flutter/cupertino.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isArMode = true;

  bool get isDarkMode => _isDarkMode;

  bool get isArMode => _isArMode;

  set isDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  set isArMode(bool value) {
    _isArMode = value;
    notifyListeners();
  }
}

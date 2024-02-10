import 'package:flutter/cupertino.dart';
import 'package:my_app/connector/shared_pref_key.dart';
import 'package:my_app/controller/shared_pref_controller.dart';

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
    SharedPrefController.sharedPrefs.setBool(SharedPrefKey.arMode, value);
  }
}

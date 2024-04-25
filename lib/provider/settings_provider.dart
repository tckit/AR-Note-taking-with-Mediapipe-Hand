import 'package:flutter/cupertino.dart';
import 'package:my_app/connector/shared_pref_key.dart';
import 'package:my_app/controller/shared_pref_controller.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isArMode = true;

  bool get isDarkMode => _isDarkMode;

  bool get isArMode => _isArMode;

  SettingsProvider() {
    try {
      _isDarkMode = SharedPrefController.sharedPrefs.getBool(SharedPrefKey.darkMode) ?? false;
      _isArMode = SharedPrefController.sharedPrefs.getBool(SharedPrefKey.arMode) ?? true;
    }
    catch (_) {
      _isDarkMode = false;
      _isArMode = true;
    }
  }

  set isDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
    SharedPrefController.sharedPrefs.setBool(SharedPrefKey.darkMode, value);
  }

  set isArMode(bool value) {
    _isArMode = value;
    notifyListeners();
    SharedPrefController.sharedPrefs.setBool(SharedPrefKey.arMode, value);
  }
}

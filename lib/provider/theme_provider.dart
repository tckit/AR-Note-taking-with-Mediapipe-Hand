import 'package:flutter/material.dart';
import 'package:my_app/connector/shared_pref_key.dart';
import 'package:my_app/controller/shared_pref_controller.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    init();
  }

  void init() async {
      try {
        // wait for shared preference to initialize
        while (!SharedPrefController.isInitialized) {
          await Future.delayed(const Duration(seconds: 1), () => null);
        }
        var isDarkMode = SharedPrefController.sharedPrefs.getBool(SharedPrefKey.darkMode) ?? false;
        _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
        notifyListeners();
      }
      catch (e) {
        debugPrint("Theme Not working $e");
      }
  }

  void toggleThemeMode() {
    _themeMode =
        (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

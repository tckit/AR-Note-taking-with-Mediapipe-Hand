import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../connector/shared_pref_key.dart';
import '../data/Document.dart';

class SharedPrefController {
  static late final SharedPreferences sharedPrefs;
  static bool isInitialized = false;

  static void initialize() async {
    sharedPrefs = await SharedPreferences.getInstance();
    isInitialized = true;
  }

  static Future<void> setPrefsForUnity(
      Document document, String currentDirectoryPath,
      [bool isPdf = false]) async {
    sharedPrefs.setString(
        SharedPrefKey.currentDirectoryPath, currentDirectoryPath);

    Directory tempDir = await getTemporaryDirectory();
    sharedPrefs.setString(SharedPrefKey.directoryPathForPdf, tempDir.path);

    sharedPrefs.setString(SharedPrefKey.userChosenFilePath, document.path);
  }

  static Future<void> testPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final x = prefs.getString(SharedPrefKey.currentDirectoryPath);
    final y = prefs.getString(SharedPrefKey.userChosenFilePath);
    final z = prefs.getString(SharedPrefKey.directoryPathForPdf);
    debugPrint(
        "Prefs are -- currentDirectoryPath: $x\n userChosenFilePath: $y\n directoryPdf: $z");
  }
}

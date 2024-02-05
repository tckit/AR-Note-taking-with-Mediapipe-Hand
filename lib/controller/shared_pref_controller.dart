import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/Document.dart';
import '../connector/shared_pref_key.dart';

class SharedPrefController {
  static Future<void> setPrefsForUnity(
      Document document, String currentDirectoryPath,
      [bool isPdf = false]) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SharedPrefKey.currentDirectoryPath, currentDirectoryPath);

    if (isPdf) {
      // use temporary directory for images
      Directory tempDir = await getTemporaryDirectory();
      String usePath = p.join(tempDir.path, document.fileName);

      // create directory for chosen files as cache
      var useDir = Directory(usePath);
      if (!(await useDir.exists())) {
        useDir.createSync();
      }
      prefs.setString(SharedPrefKey.directoryPathForPdf, usePath);
    }
    prefs.setString(SharedPrefKey.userChosenFilePath, document.path);
  }

  static Future<void> testPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final x = prefs.getString(SharedPrefKey.currentDirectoryPath);
    final y = prefs.getString(SharedPrefKey.userChosenFilePath);
    debugPrint("Prefs are -- currentDirectoryPath: $x\n userChosenFilePath: $y");
  }
}

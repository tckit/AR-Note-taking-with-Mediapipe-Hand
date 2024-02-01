import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:my_app/controller/shared_pref_controller.dart';
import 'package:my_app/viewModel/storage_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/Document.dart';
import '../data/shared_pref_key.dart';

class FlutterKotlin {
  Future<void> callKotlin(StorageViewModel viewModel, Document document) async {
    const platform = MethodChannel("kotlin/helper");

    if (document.extension == ".pdf") {
      await SharedPrefController.setPrefsForUnity(
          document, viewModel.currentDirectoryPath, true);
      generateImagesForUnity(viewModel, document.path);
    } else {
      await SharedPrefController.setPrefsForUnity(
          document, viewModel.currentDirectoryPath);
    }
    await SharedPrefController.testPrefs();

    try {
      String res =
          await platform.invokeMethod("test", {"testvar": "string of var"});
      debugPrint("Called kotlin function $res");
    } on PlatformException catch (e) {
      debugPrint("Cannot call kotlin function $e");
    }
  }

  void generatePdfFromImages(StorageViewModel viewModel) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String? dirPath = sharedPref.getString(SharedPrefKey.userChosenFilePath);
    if (dirPath == null) {
      debugPrint("Cannot generate Pdf. No Directory path found");
      return;
    }
    debugPrint("Generating pdf");
    viewModel.generatePdfFromImages(dirPath, "File25.pdf");
  }

  /// generate images from pdf.
  ///
  /// For use in Unity
  void generateImagesForUnity(StorageViewModel viewModel, String path) {
    debugPrint("Extracting images from pdf");
    viewModel.generateImagesFromPdf(path);
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:my_app/controller/shared_pref_controller.dart';
import 'package:my_app/viewModel/storage_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/Document.dart';
import 'shared_pref_key.dart';

class FlutterKotlin {
  /// Click on image: go to Unity.
  /// Return back from Unity
  ///
  /// Click on pdf: [generateImagesForUnity], go to Unity.
  /// Return back from Unity, get all images, [generatePdfFromImages]
  Future<void> callKotlin(StorageViewModel viewModel, Document document) async {
    const platform = MethodChannel("kotlin/helper");
    await setSharedPrefs(viewModel, document);

    try {
      // String res = await platform.invokeMethod("test", {"testVar": "string var"});
      String res = await platform.invokeMethod("callUnity");
      debugPrint("Called kotlin function $res");
    } on PlatformException catch (e) {
      debugPrint("Cannot call kotlin function $e");
    }
  }

  Future<void> setSharedPrefs(
      StorageViewModel viewModel, Document document) async {
    if (document.extension == ".pdf") {
      await SharedPrefController.setPrefsForUnity(
          document, viewModel.currentDirectoryPath, true);
      generateImagesForUnity(viewModel, document.path);
    } else {
      await SharedPrefController.setPrefsForUnity(
          document, viewModel.currentDirectoryPath);
    }
    await SharedPrefController.testPrefs();
  }

  void generatePdfFromImages(StorageViewModel viewModel) async {
    SharedPreferences sharedPref = SharedPrefController.sharedPrefs;
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

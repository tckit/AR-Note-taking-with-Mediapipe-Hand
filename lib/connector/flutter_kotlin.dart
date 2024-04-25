import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:my_app/controller/shared_pref_controller.dart';
import 'package:my_app/data/document_type.dart';
import 'package:my_app/viewModel/storage_view_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

import '../data/Document.dart';
import 'shared_pref_key.dart';

class FlutterKotlin {
  /// Click on image: go to Unity.
  /// Return back from Unity
  ///
  /// Click on pdf: get images from temp directory, go to Unity.
  /// Return back from Unity, get all images, [generatePdfFromImages]
  Future<void> callKotlin(StorageViewModel viewModel, Document document) async {
    const platform = MethodChannel("kotlin/helper");
    await setSharedPrefs(viewModel, document);
    if (document.extension == DocumentType.pdf)
    viewModel.listFiles(p.join((await getTemporaryDirectory()).path, document.fileName));

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
    if (document.extension == DocumentType.pdf) {
      await SharedPrefController.setPrefsForUnity(
          document, viewModel.currentDirectoryPath, true);

      // create directory for images if it does not exist
      if (!await viewModel.checkPdfDirectoryNameExist(document.fileName)) {
        await viewModel.createDirectoryForPdfImages(document);
        generateImagesForUnity(viewModel, document.path);
      }
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
    viewModel.generateImagesFromPdf(path, true);
  }
}

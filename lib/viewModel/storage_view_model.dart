import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_app/data/Document.dart';
import 'package:my_app/data/Stack.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfrx/pdfrx.dart' as pr;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageViewModel with ChangeNotifier {
  /// Queue implemented to represent a Stack
  final ListStack<List<Document>> _userDocuments = ListStack();
  final List<int> _selectedFilesIndex = [];
  final String documentFolder = "Documents";

  List<int> get selectedFilesIndex => _selectedFilesIndex;

  /// Resolves to latest directory user sees
  String currentDirectoryPath = "";

  /// Saves the original directory before moving to another directory
  final List<Document> _moveDocuments = [];

  List<Document> get moveDocuments => _moveDocuments;

  /// For indexing in fileName
  int fileCount = 0;

  bool _isTemporaryView = false;

  StorageViewModel() {
    SharedPreferences.setPrefix("");
    initDirectory();
    requestPermission();
  }

  Future<void> requestPermission() async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      debugPrint("granted permission");
    } else {
      debugPrint("not granted");
    }
  }

  void initDirectory() async {
    try {
      await cleanTempFiles();

      Directory currentDirectory = Directory(await _localDocumentPath);
      currentDirectory.createSync();
      currentDirectoryPath = currentDirectory.path;
      debugPrint("Directory created at ${await _localDocumentPath}");
    } catch (e) {
      debugPrint("Unable to create Documents Directory");
    }
  }

  Future<void> cleanTempFiles() async {
    var tempDir = await getTemporaryDirectory();
    for (var file in tempDir.listSync()) {
      try {
        file.deleteSync();
      } catch (e) {
        continue;
      }
    }
  }

  // Return the files for the current directory
  List<Document> get getUserDocuments {
    if (_userDocuments.isEmpty) return [];
    return _userDocuments.top;
  }

  void _replaceCurrentUserDocuments(List<Document> replaceWith) {
    if (_userDocuments.isEmpty) return;
    _userDocuments.pop();
    _userDocuments.push(replaceWith);
  }

  Future<Directory> get _appDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  Future<String> get _appPath async {
    return (await _appDirectory).path;
  }

  Future<String> get _localDocumentPath async {
    return p.join(await _appPath, documentFolder);
  }

  /// Get files from provided directory path in Documents Directory
  Future<void> getListOfFiles([String? directoryPath]) async {
    var path = await getAbsolutePath(directoryPath);
    final List<FileSystemEntity> files =
        Directory(path).listSync(recursive: true);

    for (final FileSystemEntity file in files) {
      final FileStat fileStat = await file.stat();
      print('Path: ${file.path}');
      print('Type: ${fileStat.type}');
      print('Size: ${fileStat.size}');
    }
    debugPrint("Files count: ${files.length}");
  }

  Future<List<PlatformFile>?> _pickFiles() async {
    FilePickerResult? res = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'webp']);

    if (res != null) {
      List<PlatformFile> files = res.files.map((file) => file).toList();
      return files;
    }
    return null;
  }

  /// User choose to import file
  ///
  /// Returns the imported document. Otherwise, return null
  Future<Document?> importFile([String? fileName]) async {
    List<PlatformFile>? files = await _pickFiles();
    if (files == null) return null;

    Document? returnedDoc;
    for (var file in files) {
      try {
        // path from file_picker differs from Application Directory
        var path = file.path!;

        fileCount++;
        fileName = "File$fileCount";
        // Import to the currently viewed directory
        var newPath =
            p.join(currentDirectoryPath, fileName + p.extension(path));
        await copyFile(path, newPath);
        debugPrint("Image path imported from: $path");

        createAndAddDocumentData(await getAbsolutePath(newPath));
      } catch (e) {
        debugPrint("Failed to import file");
        return null;
      }
    }
    notifyListeners();
    return returnedDoc;
  }

  /// Load all user's files at startup
  Future<bool> loadFiles() async {
    // Must be empty since it is the first function to be called
    if (_userDocuments.isNotEmpty) {
      _userDocuments.clear();
    }
    currentDirectoryPath = await _localDocumentPath;

    // createDirectory("test1/test3");
    _userDocuments.push(await loadFilesFrom());
    notifyListeners();
    return true;
  }

  /// Load all user's files at given directory in Documents Directory
  ///
  /// Return all files obtained in the given directory
  Future<List<Document>> loadFilesFrom([String? directoryPath]) async {
    List<Document> documents = [];
    var files = Directory(await getAbsolutePath(directoryPath)).listSync();
    for (final FileSystemEntity file in files) {
      Document doc = createDocumentData(file.path);
      documents.add(doc);
    }
    documents = _sortFiles(documents);

    fileCount = countFileForNaming(documents);
    return documents;
  }

  /// Load all user's files at given directory.
  /// Absolute path should be provided
  ///
  /// Return all files obtained in the given directory
  List<Document> loadFilesFromSync(String directoryPath) {
    List<Document> documents = [];
    var files = Directory(directoryPath).listSync();
    for (final FileSystemEntity file in files) {
      Document doc = createDocumentData(file.path);
      documents.add(doc);
    }
    documents = _sortFiles(documents);

    fileCount = countFileForNaming(documents);
    return documents;
  }

  /// Newly created file starts with prefixFileName[maxCount]
  int countFileForNaming(List<Document> documents) {
    int maxCount = 1;
    for (var x in documents) {
      debugPrint("fileName in Documents Directory: ${p.basename(x.path)}");
      int? num =
          int.tryParse(p.basename(x.path).replaceAll(RegExp(r'[^0-9]'), ''));

      if (num == null) continue;
      maxCount = (num > maxCount) ? num : maxCount;
    }
    return maxCount;
  }

  /// Sort by number in fileName
  int sortPaths(Document a, Document b) {
    try {
      int num1 =
          int.parse(p.basename(a.path).replaceAll(RegExp(r'[^0-9]'), ''));
      int num2 =
          int.parse(p.basename(b.path).replaceAll(RegExp(r'[^0-9]'), ''));

      return num1.compareTo(num2);
    } catch (e) {
      debugPrint("sortPaths error: ${e.toString()}");
      return 0;
    }
  }

  /// Create file in Documents Directory
  Future<bool> createFile(String filePath) async {
    if (filePath.isEmpty) return false;

    try {
      var path = await getAbsolutePath(filePath);
      final File file = File(path);
      await file.create();

      createAndAddDocumentData(path);
      debugPrint("Created file: ${file.path}");
    } catch (e) {
      debugPrint("Failed to create file");
      return false;
    }
    notifyListeners();
    return true;
  }

  /// Create directory / folder in Documents Directory
  Future<bool> createDirectory(String dirPath) async {
    if (dirPath.isEmpty) return false;

    try {
      var path = await getAbsolutePath(dirPath);
      final Directory dir = Directory(path);
      await dir.create();

      createAndAddDocumentData(path);
      debugPrint("Created dir: ${dir.path}");
    } catch (e) {
      debugPrint("Failed to create dir");
      return false;
    }
    notifyListeners();
    return true;
  }

  /// Open file in Documents Directory
  Future<bool> openFile(String filePath) async {
    try {
      var path = await getAbsolutePath(filePath);
      final File file = File(path);
      debugPrint("Opened $filePath: ${await file.readAsString()}");
    } catch (e) {
      debugPrint("Failed to open file");
      return false;
    }
    notifyListeners();
    return true;
  }

  /// Copy file from one path to another path
  Future<bool> copyFile(String fromPath, String newPath) async {
    try {
      final File file = File(await getAbsolutePath(fromPath));
      File copyFile = await file.copy(await getAbsolutePath(newPath));

      debugPrint("Copied file: ${copyFile.path}");
    } catch (e) {
      debugPrint("Failed to copy file $e");
      return false;
    }
    return true;
  }

  Future<bool> moveFile(Document oldDocument, String newFilePath) async {
    try {
      if (oldDocument.isDirectory) return false;

      if (isSameFile(oldDocument.path, newFilePath)) {
        debugPrint("Files in same directory. No move done.");
        return true;
      }
      await copyFile(oldDocument.path, newFilePath);
      await deleteOldMoveDocuments(oldDocument);
      createAndAddDocumentData(newFilePath);
    } catch (e) {
      debugPrint("Failed to copy file $e");
      return false;
    }
    notifyListeners();
    return true;
  }

  /// Call after selecting documents to be moved
  ///
  /// Selected documents will be saved to [moveDocuments]
  void startMoveDocuments() {
    if (_moveDocuments.isNotEmpty) _moveDocuments.clear();

    for (final index in _selectedFilesIndex) {
      var document = getUserDocuments[index];
      // only files can be moved
      if (document.isDirectory) continue;
      _moveDocuments.add(document);
    }
    refToOldDocuments = getUserDocuments;
  }

  List<Document> refToOldDocuments = [];

  Future<bool> deleteOldMoveDocuments(Document oldDocument) async {
    try {
      File file = File(oldDocument.path);
      var doc =
          refToOldDocuments.firstWhere((doc) => p.equals(doc.path, file.path));

      FileSystemEntity deletedFile = await file.delete();
      refToOldDocuments.remove(doc);
      debugPrint("Deleted moved file: ${deletedFile.path}");
    } catch (e) {
      debugPrint("Failed to delete file $e");
      return false;
    }
    return true;
  }

  /// Rename file in Documents Directory
  ///
  /// Failure: -1, Success: 0, No rename done: 1
  Future<int> renameFile(String oldFilePath, String newFilePath) async {
    int ret;
    try {
      String oldPath = await getAbsolutePath(oldFilePath);
      final File file = File(oldPath);

      String newPath =
          await getAbsolutePath(newFilePath, p.dirname(oldFilePath));
      int? oldDocumentIndex;
      debugPrint("original: ${file.path}");
      debugPrint("new: $newPath");
      for (final (index, doc) in getUserDocuments.indexed) {
        // Find for any file path that have same path as newPath
        if (isSameFile(doc.path, newPath)) {
          debugPrint("Same file name. Renamed aborted successfully");
          return 1;
        }
        // Find for index of old path
        if (doc.path.contains(file.path)) {
          oldDocumentIndex = index;
        }
      }
      if (oldDocumentIndex == null) throw "Unable to find fileName";
      // Rename file only if the new file path does not already exist
      File renamedFile = await file.rename(newPath);
      getUserDocuments[oldDocumentIndex].path = renamedFile.path;
      debugPrint("Renamed file: ${renamedFile.path}");
      ret = 0;
    } catch (e) {
      debugPrint("Failed to rename file $e");
      ret = -1;
    }
    notifyListeners();
    return ret;
  }

  /// Rename directory/folder in Documents Directory
  ///
  /// Failure: -1, Success: 0, No rename done: 1
  Future<int> renameDirectory(String oldDirPath, String newDirPath) async {
    int ret;
    try {
      String oldPath = await getAbsolutePath(oldDirPath);
      final dir = Directory(oldPath);

      String newPath = await getAbsolutePath(newDirPath, p.dirname(oldDirPath));
      int? oldDocumentIndex;
      debugPrint("original: ${dir.path}");
      debugPrint("new: $newPath");
      for (final (index, doc) in getUserDocuments.indexed) {
        // Find for any file path that have same path as newPath
        if (isSameFile(doc.path, newPath)) {
          debugPrint("Same directory name. Renamed aborted successfully");
          return 1;
        }
        // Find for index of old path
        if (doc.path.contains(dir.path)) {
          oldDocumentIndex = index;
        }
      }
      if (oldDocumentIndex == null) throw "Unable to find directory";
      // Rename file only if the new file path does not already exist
      Directory renamedDir = await dir.rename(newPath);
      getUserDocuments[oldDocumentIndex].path = renamedDir.path;
      debugPrint("Renamed directory: ${renamedDir.path}");
      ret = 0;
    } catch (e) {
      debugPrint("Failed to rename directory $e");
      ret = -1;
    }
    notifyListeners();
    return ret;
  }

  /// Check if [oldPath] has same file as [newPath]
  bool isSameFile(String oldPath, String newPath) {
    if (oldPath.contains(newPath)) {
      return true;
    }
    return false;
  }

  /// Delete file in Documents Directory
  Future<bool> deleteFile(String filePath) async {
    try {
      String path = await getAbsolutePath(filePath);
      final File file = File(path);
      var doc =
          getUserDocuments.firstWhere((doc) => p.equals(doc.path, file.path));

      FileSystemEntity deletedFile = await file.delete();
      getUserDocuments.remove(doc);
      debugPrint("Deleted file: ${deletedFile.path}");
    } catch (e) {
      debugPrint("Failed to delete file $e");
      return false;
    }
    notifyListeners();
    return true;
  }

  /// Delete folder / directory in Documents Directory
  ///
  /// deleteAll true will remove all contents
  Future<bool> deleteDirectory(String dirPath, [bool deleteAll = false]) async {
    try {
      String path = await getAbsolutePath(dirPath);
      final Directory dir = Directory(path);
      var doc =
          getUserDocuments.firstWhere((doc) => p.equals(doc.path, dir.path));

      FileSystemEntity deletedDir = await dir.delete(recursive: deleteAll);
      getUserDocuments.remove(doc);
      debugPrint("Deleted dir: ${deletedDir.path}");
    } catch (e) {
      debugPrint("Failed to delete dir $e");
      return false;
    }
    notifyListeners();
    return true;
  }

  /// Add or remove file current index according to received [index]
  void addOrRemoveSelectedFiles(int index) {
    assert(index <= getUserDocuments.length,
        "Homepage current view index more than no. of internal file");

    debugPrint("Added file, index $index");
    if (_selectedFilesIndex.contains(index)) {
      // User unselect the file
      _selectedFilesIndex.remove(index);
    } else {
      _selectedFilesIndex.add(index);
    }
  }

  /// Only empty directory can be deleted.
  ///
  /// Success: 0, Cannot delete dir: 1, Cannot delete file: 2
  Future<int> bulkDeleteFiles() async {
    debugPrint("index marked for deletion... ${_selectedFilesIndex.join(',')}");
    for (var index in _selectedFilesIndex) {
      var currentDocumentPath = getUserDocuments[index].path;
      if (isDirectory(currentDocumentPath)) {
        if (!(await deleteDirectory(currentDocumentPath))) {
          return 1;
        }
      } else {
        if (!(await deleteFile(currentDocumentPath))) {
          return 2;
        }
      }
      debugPrint("Bulk deleting... deleting $currentDocumentPath");
    }
    clearSelection();
    return 0;
  }

  /// Provide index of the current documents to navigate
  Future<void> goToNextDirectory(int index) async {
    String path = getUserDocuments[index].path;
    var newDocumentsList = await loadFilesFrom(path);
    _userDocuments.push(newDocumentsList);
    currentDirectoryPath = path;

    debugPrint("Entering another directory... ${newDocumentsList.toString()}");
    notifyListeners();
  }

  Future<void> goToPrevDirectory() async {
    _userDocuments.pop();
    // Assume last file is a file
    currentDirectoryPath = p.dirname(getUserDocuments.last.path);
    debugPrint(
        "Going back to previous directory... ${getUserDocuments.toString()}");
    notifyListeners();
  }

  /// Return absolute path in Documents Directory given relative or absolute path.
  /// If path is null, return Documents Directory
  ///
  /// defaultPath sets the directory of the absolute path. Defaults at Documents Directory
  Future<String> getAbsolutePath(
      [String? path, String? defaultDirectoryPath]) async {
    defaultDirectoryPath ??= currentDirectoryPath;
    if (path == null) return defaultDirectoryPath;

    debugPrint("Getting abs path: $path and $defaultDirectoryPath");
    String finalPath;
    if (path.contains(defaultDirectoryPath)) {
      // filePath is absolute path
      finalPath = path;
    } else {
      // filePath is relative path
      finalPath = p.join(defaultDirectoryPath, path);
    }
    return finalPath;
  }

  Document createDocumentData(String path) {
    return Document(path: path, isDirectory: isDirectory(path));
  }

  /// [path] must be absolute path
  void createAndAddDocumentData(String path) {
    Document doc = Document(path: path, isDirectory: isDirectory(path));
    for (var document in getUserDocuments) {
      // check if document exists already
      if (document.path == path) {
        return;
      }
    }
    getUserDocuments.add(doc);
  }

  /// Clear pending deletion for view
  void clearSelection() {
    _selectedFilesIndex.clear();
    notifyListeners();
  }

  List<Document> searchFiles(String searchName) {
    List<Document> originalDoc;
    if (_isTemporaryView) {
      // get second last element, where last element is temporary view
      originalDoc = _userDocuments.elementAt(_userDocuments.length - 2);
    } else {
      originalDoc = getUserDocuments;
    }
    return originalDoc
        .where((document) =>
            document.fileName.toLowerCase().contains(searchName.toLowerCase()))
        .toList();
  }

  /// Gets a temporary view resulting from the search
  void getTemporaryView(List<Document> documentsToView) {
    // User is searching / typing
    if (_isTemporaryView) {
      _replaceCurrentUserDocuments(documentsToView);
    }
    // User starts search for the first time
    else {
      _isTemporaryView = true;
      _userDocuments.push(documentsToView);
    }
    notifyListeners();
  }

  void removeTemporaryView() {
    if (_isTemporaryView) {
      _isTemporaryView = false;
      _userDocuments.pop();
      notifyListeners();
    }
  }

  /// Sort directory and files separately
  /// Directory shown first, followed by other files
  List<Document> _sortFiles(List<Document> documentsToSort,
      [bool sortAsc = true]) {
    List<Document> dirDocuments = [];
    List<Document> fileDocuments = [];
    for (var document in documentsToSort) {
      if (document.isDirectory) {
        dirDocuments.add(document);
      } else {
        fileDocuments.add(document);
      }
    }

    if (sortAsc) {
      dirDocuments.sort((a, b) => _sortFilesByName(a, b));
      fileDocuments.sort((a, b) => _sortFilesByName(a, b));
    } else {
      dirDocuments.sort((b, a) => _sortFilesByName(a, b));
      fileDocuments.sort((b, a) => _sortFilesByName(a, b));
    }
    List<Document> newDocuments = [...dirDocuments, ...fileDocuments];
    return newDocuments;
  }

  void sortAndUpdateUI([bool sortAsc = true]) {
    var documents = _sortFiles(getUserDocuments, sortAsc);
    _replaceCurrentUserDocuments(documents);
    notifyListeners();
  }

  int _sortFilesByName(Document a, Document b) {
    return a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase());
  }

  /// returns index if one file selected, else -1
  int isOneFileSelected(Map<int, bool> isSelected) {
    try {
      var selectedList = isSelected.values.toList();
      var chosenFile = selectedList.singleWhere((element) => element == true);
      int index = selectedList.indexOf(chosenFile);
      return index;
    } catch (e) {
      debugPrint("More than one file selected: $e");
      return -1;
    }
  }

  bool isDirectory(String path) {
    var fileStat = File(path).statSync();
    if (fileStat.type == FileSystemEntityType.directory) {
      return true;
    }
    return false;
  }

  bool isHomePage() {
    return _userDocuments.length <= 1;
  }

  /// Ignore directory by default.
  Future<bool> shareFiles(RenderBox? box) async {
    List<XFile> files = [];
    // get all files selected
    for (int index in _selectedFilesIndex) {
      var document = getUserDocuments[index];
      if (document.isDirectory) continue;

      files.add(XFile(document.path));
      requestPermission();
    }

    if (files.isEmpty) return false;
    try {
      // iPads require sharePositionOrigin
      final result = await Share.shareXFiles(files,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
      if (result.status == ShareResultStatus.success) {
        return true;
      }
    } catch (e) {
      debugPrint("Share files failed: $e");
    }
    return false;
  }

  Future<void> createBlankImage() async {
    PictureRecorder recorder = PictureRecorder();
    Canvas(recorder);
    var pic = recorder.endRecording();
    var img = await pic.toImage(800, 800);
    var bytes = await img.toByteData(format: ImageByteFormat.png);
    var bytesList = bytes?.buffer.asUint8List();

    final file = File(await getAbsolutePath("File1.png"));
    await file.writeAsBytes(bytesList!);
    createAndAddDocumentData(file.path);
    notifyListeners();
  }

  Future<Uint8List> generatePdfFromImage(
      String filePath, String pdfName) async {
    File img = File(await getAbsolutePath(filePath));
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (_) {
          return pw.Center(
              child: pw.Image(pw.MemoryImage(img.readAsBytesSync()),
                  fit: pw.BoxFit.cover));
        }));

    File createdPdf = await saveDocument(await pdf.save(), pdfName);
    createAndAddDocumentData(createdPdf.path);
    notifyListeners();
    return pdf.save();
  }

  /// Get all images from the directory.
  ///
  /// Ensure only images exist in the directory.
  /// Ignores directory and pdf by default.
  Future<Uint8List> generatePdfFromImages(
      String dirPath, String pdfName) async {
    final dir = Directory(dirPath);
    final pdf = pw.Document();

    for (var file in dir.listSync()) {
      // ignore directory and pdf
      if (file.statSync().type != FileSystemEntityType.file) continue;
      if (p.extension(file.path) == ".pdf") continue;

      File img = File(file.path);
      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (_) {
            return pw.Center(
                child: pw.Image(pw.MemoryImage(img.readAsBytesSync()),
                    fit: pw.BoxFit.cover));
          }));
    }

    File createdPdf = await saveDocument(await pdf.save(), pdfName);
    createAndAddDocumentData(createdPdf.path);
    notifyListeners();
    return pdf.save();
  }

  /// Save document in the Documents directory
  Future<File> saveDocument(Uint8List imgBytes, String fileName) async {
    final file = File(await getAbsolutePath(fileName));
    return file.writeAsBytes(imgBytes);
  }

  /// Extract all pages from pdf as images.
  ///
  /// Images extracted will be placed in Documents current directory.
  /// All images name will be in integer only
  Future<void> generateImagesFromPdf(String filePath) async {
    pr.PdfDocument file =
        await pr.PdfDocument.openFile(await getAbsolutePath(filePath));

    int fileCount = 1;
    for (var page in file.pages) {
      var pdfImg = await page.render() as pr.PdfImage;
      var img = await pdfImg.createImage();

      var bytes = await img.toByteData(format: ImageByteFormat.png);
      var imgBytes = bytes?.buffer.asUint8List();

      File createdFile = await saveDocument(imgBytes!, "$fileCount.png");
      createAndAddDocumentData(createdFile.path);
      debugPrint("Pdf created: $fileCount");
      fileCount++;
    }
    file.dispose();
    notifyListeners();
  }
}

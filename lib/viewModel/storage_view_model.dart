import 'dart:collection';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_app/data/Document.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:my_app/data/Stack.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageViewModel with ChangeNotifier {
  // Queue implemented to represent a Stack
  final ListStack<List<Document>> _userDocuments = ListStack();
  final List<int> _fileForDeletionIndex = [];
  final String documentFolder = "Documents";

  // Resolves to latest directory user sees
  String currentDirectoryPath = "";

  // For indexing in fileName
  int fileCount = 0;

  StorageViewModel() {
    SharedPreferences.setPrefix("");
    initDirectory();
  }

  void initDirectory() async {
    try {
      Directory currentDirectory = Directory(await _localDocumentPath);
      currentDirectory.createSync();
      currentDirectoryPath = currentDirectory.path;
      debugPrint("Directory created at ${await _localDocumentPath}");
    } catch (e) {
      debugPrint("Unable to create Documents Directory");
    }
  }

  // Return the files for the current directory
  List<Document> get getUserDocuments {
    if (_userDocuments.isEmpty) return [];
    return _userDocuments.top;
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
      type: FileType.image,
    );

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
        var newPath = p.join(currentDirectoryPath, fileName + p.extension(path));
        await copyFile(path, newPath);
        debugPrint("Image path imported from: $path");

        var filePath = await getAbsolutePath(newPath);
        returnedDoc =
            Document(path: filePath, isDirectory: isDirectory(filePath));
        getUserDocuments.add(returnedDoc);
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

    createDirectory("test1/test3");
    //copyFile("File2.jpg", "test1/File10.jpg");
    _userDocuments.push(await loadFilesFrom());
    notifyListeners();
    return true;
  }

  /// Load all user's files at given directory in Documents Directory
  ///
  /// Return all files obtained in the given directory
  Future<List<Document>> loadFilesFrom([String? directoryPath]) async {
    List<Document> documents = [];
    var files =
        Directory(await getAbsolutePath(directoryPath)).listSync();
    for (final FileSystemEntity file in files) {
      final FileStat fileStat = file.statSync();
      Document doc = Document(path: file.path);
      if (fileStat.type == FileSystemEntityType.file) {
        doc.isDirectory = false;
      } else if (fileStat.type == FileSystemEntityType.directory) {
        doc.isDirectory = true;
      }
      documents.add(doc);
    }
    documents.sort(sortPaths);

    // try diffutil to check for differences between files
    // userFiles = files;
    int maxCount = 0;
    for (var x in documents) {
      debugPrint("fileName in Documents Directory: ${p.basename(x.path)}");
      int num = int.parse(p.basename(x.path).replaceAll(RegExp(r'[^0-9]'), ''));
      maxCount = (num > maxCount) ? num : maxCount;
    }
    fileCount = maxCount;
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
      final FileStat fileStat = file.statSync();
      Document doc = Document(path: file.path);
      if (fileStat.type == FileSystemEntityType.file) {
        doc.isDirectory = false;
      } else if (fileStat.type == FileSystemEntityType.directory) {
        doc.isDirectory = true;
      }
      documents.add(doc);
    }
    documents.sort(sortPaths);

    // try diffutil to check for differences between files
    // userFiles = files;
    int maxCount = 0;
    for (var x in documents) {
      debugPrint("fileName in Documents Directory: ${p.basename(x.path)}");
      int num = int.parse(p.basename(x.path).replaceAll(RegExp(r'[^0-9]'), ''));
      maxCount = (num > maxCount) ? num : maxCount;
    }
    fileCount = maxCount;
    return documents;
  }

  /// Sort by number in fileName
  int sortPaths(Document a, Document b) {
    int num1 = int.parse(p.basename(a.path).replaceAll(RegExp(r'[^0-9]'), ''));
    int num2 = int.parse(p.basename(b.path).replaceAll(RegExp(r'[^0-9]'), ''));
    return num1.compareTo(num2);
  }

  /// Create file in Documents Directory
  Future<bool> createFile(String filePath) async {
    try {
      var path = await getAbsolutePath(filePath);
      final File file = File(path);
      await file.create();
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
    try {
      var path = await getAbsolutePath(dirPath);
      final Directory dir = Directory(path);
      await dir.create();
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
      debugPrint("Failed to copy file");
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

      String newPath = await getAbsolutePath(newFilePath, p.dirname(oldFilePath));
      int? oldDocumentIndex;
      debugPrint("original: ${file.path}");
      debugPrint("new: $newPath");
      for (final (index, doc) in  getUserDocuments.indexed) {
        // Find for any file path that have same path as newPath
        if (doc.path.contains(newPath)) {
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
      for (final (index, doc) in  getUserDocuments.indexed) {
        // Find for any file path that have same path as newPath
        if (doc.path.contains(newPath)) {
          debugPrint("Same file name. Renamed aborted successfully");
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

  /// Delete file in Documents Directory
  Future<bool> deleteFile(String filePath) async {
    try {
      String path = await getAbsolutePath(filePath);
      final File file = File(path);
      var doc = getUserDocuments
          .firstWhere((doc) => p.equals(doc.path, file.path));

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
      var doc = getUserDocuments
          .firstWhere((doc) => p.equals(doc.path, dir.path));

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

  /// Add grid or list view current index for pending deletion
  void addFileToDelete(int index) {
    assert(index <= getUserDocuments.length,
        "Homepage current view index more than no. of internal file");

    debugPrint("File to delete $index");
    if (_fileForDeletionIndex.contains(index)) {
      // User unselect the file
      _fileForDeletionIndex.remove(index);
    } else {
      _fileForDeletionIndex.add(index);
    }
  }

  void bulkDeleteFiles() {
    debugPrint("index marked for deletion... ${_fileForDeletionIndex.join(',')}");
    for (var index in _fileForDeletionIndex) {
      var currentDocumentPath = getUserDocuments[index].path;
      if (isDirectory(currentDocumentPath)) {
        deleteDirectory(currentDocumentPath);
      } else {
        deleteFile(currentDocumentPath);
      }
      debugPrint("Bulk deleting... deleting $currentDocumentPath");
    }
    clearSelection();
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
    currentDirectoryPath = p.dirname(getUserDocuments.first.path);
    debugPrint("Going back to previous directory... ${_userDocuments.top.toString()}");
    notifyListeners();
  }
  
  /// Return absolute path in Documents Directory given relative or absolute path.
  /// If path is null, return Documents Directory
  /// 
  /// defaultPath sets the directory of the absolute path. Defaults at Documents Directory
  Future<String> getAbsolutePath([String? path, String? defaultDirectoryPath]) async {
    defaultDirectoryPath ??= await _localDocumentPath;
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

  /// Clear pending deletion for view
  void clearSelection() {
    _fileForDeletionIndex.clear();
    notifyListeners();
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
  
  Future<void> setPrefsForUnity(int documentIndex) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("documentsPath", currentDirectoryPath);
    prefs.setString("userChosenFilePath", getUserDocuments[documentIndex].path);
  }

  Future<void> testPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final x = prefs.getString("documentsPath");
    final y = prefs.getString("userChosenFilePath");
    debugPrint("Prefs at: $x\n $y");
  }

  Future<void> test() async {
    await _appDirectory;
    await _appPath;
    await _localDocumentPath;
  }
}

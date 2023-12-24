import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/connector/FlutterKotlin.dart';
import 'package:my_app/data/Document.dart';
import 'package:my_app/ui/folder_tree_page.dart';
import 'package:my_app/viewModel/storage_view_model.dart';
import 'package:provider/provider.dart';
import 'package:my_app/provider/homepage_provider.dart';
import 'package:path/path.dart' as p;

import '../strings/strings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final FlutterKotlin? connector = FlutterKotlin();
  bool selectionMode = false;
  Map<int, bool> isSelected = {};

  @override
  void initState() {
    super.initState();
    // var provider = context.read<HomePageProvider>();
    // provider.bottomNavBarIndex = 0;
    var viewModel = context.read<StorageViewModel>();
    viewModel.loadFiles();
    debugPrint("building HomePage init");
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("building HomePage");
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: selectionMode
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: closeSelectionMode,
            )
          : IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FolderTreePage())),
            ),
      title: const Text(AppStrings.appTitle),
      centerTitle: true,
      actions: [
        Consumer<HomePageProvider>(builder: (_, provider, __) {
          if (provider.bottomNavBarIndex == 0) {
            return IconButton(
              icon: Icon(Icons.grid_view_rounded),
              selectedIcon: Icon(Icons.list_rounded),
              isSelected: provider.isGridView(),
              tooltip: 'Change view',
              onPressed: () => provider.toggleHomePageView(),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildBody() {
    final currentIndex = context.watch<HomePageProvider>().bottomNavBarIndex;

    if (currentIndex == 0) {
      return Column(children: <Widget>[
        (selectionMode) ? _buildSelectionTopRightIcon() : _buildTopRightIcons(),
        Expanded(child: _selectGridOrListView()),
      ]);
    } else if (currentIndex == 1) {
      return const Column(children: <Widget>[
        Text('data'),
      ]);
    } else {
      return const Center(
        child: Text('Unable to build body'),
      );
    }
  }

  Widget _selectGridOrListView() {
    return Consumer2<HomePageProvider, StorageViewModel>(
      builder: (_, provider, viewModel, __) {
        if (provider.homePageView == ViewTypes.grid) {
          return _buildGridView(viewModel);
        }
        return _buildListView(viewModel);
      },
    );
  }

  GridView _buildGridView(StorageViewModel viewModel) {
    final documents = viewModel.userDocuments;
    viewModel.getListOfFiles();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 2.5,
      ),
      itemCount: documents.length,
      itemBuilder: (_, int index) {
        // initialize isSelected with false
        isSelected[index] = isSelected[index] ?? false;
        String currentFilePath = documents[index].path;
        bool isDirectory = viewModel.isDirectory(currentFilePath);

        return InkWell(
          onLongPress: () => onLongPressFile(index, isDirectory),
          child: GridTile(
            header: Container(
              alignment: Alignment.center,
              child: _buildSelectionBox(isSelected[index]!),
            ),
            footer: Center(
              child: documents.isEmpty
                  ? const Text("Desc")
                  : Text(p.basename(currentFilePath)),
            ),
            child: IconButton(
              icon: isDirectory
                  ? const Icon(Icons.folder)
                  : Image(
                      image: FileImage(File(currentFilePath)),
                      height: 200,
                    ),
              iconSize: 100,
              onPressed: () {
                onTapFile(index, isDirectory);
                connector?.callKotlin();
              }
            ),
          ),
        );
      },
    );
  }

  ListView _buildListView(StorageViewModel viewModel) {
    final documents = viewModel.userDocuments;

    return ListView.builder(
        itemCount: documents.length,
        itemBuilder: (_, int index) {
          // initialize isSelected with false
          isSelected[index] = isSelected[index] ?? false;
          String currentFilePath = documents![index].path;
          bool isDirectory = viewModel.isDirectory(currentFilePath);

          return ListTile(
            onLongPress: () => onLongPressFile(index, isDirectory),
            onTap: () {
              onTapFile(index, isDirectory);
              connector?.callKotlin();
            },
            title: Row(
              children: [
                isDirectory ? const Icon(Icons.folder) : const Icon(Icons.image),
                const SizedBox(width: 10),
                // fileName
                documents.isEmpty ? Text("Desc") : Text(p.basename(currentFilePath)),
              ],
            ),
            trailing: _buildSelectionBox(isSelected[index]!),
          );
        });
  }

  /// Create selection box for each element created
  Widget _buildSelectionBox(bool isSelected) {
    if (selectionMode) {
      return Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildTopRightIcons() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <IconButton>[
        IconButton(
          onPressed: null,
          icon: Icon(Icons.search),
          tooltip: 'Add button here',
        ),
        IconButton(
          onPressed: null,
          icon: Icon(Icons.sort_by_alpha),
          tooltip: 'Add button here',
        ),
        IconButton(
          onPressed: null,
          icon: Icon(Icons.filter_alt),
          tooltip: 'Add button here',
        ),
      ],
    );
  }

  Widget _buildSelectionTopRightIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(onPressed: deleteFiles, icon: const Icon(Icons.delete)),
        IconButton(
            onPressed: () => _renameFileAlertDialog(context),
            icon: const Icon(Icons.drive_file_rename_outline_rounded)),
        IconButton(onPressed: deleteFiles, icon: const Icon(Icons.delete)),
      ],
    );
  }

  /// Used during selection mode
  void onLongPressFile(int index, bool isDirectory) {
    if (!selectionMode) {
      setState(() {
        selectionMode = true;
      });
      onTapFile(index, isDirectory);
    } else {
      closeSelectionMode();
    }
  }

  void onTapFile(int index, bool isDirectory) async {
    var viewModel = context.read<StorageViewModel>();
    debugPrint("Tapped file ${isSelected[index]}");
    if (selectionMode) {
      pendingDeleteFiles(index);
    } else
      if (isDirectory) {
        String path = viewModel.userDocuments[index].path;
        var newDocuments = viewModel.loadFilesFrom(path);
        debugPrint("Entering another directory... ${newDocuments.toString()}");

      }

  }

  /// Mark files for deletion during selection mode
  void pendingDeleteFiles(int index) {
    var viewModel = context.read<StorageViewModel>();
    viewModel.addFileToDelete(index);

    setState(() {
      isSelected[index] = !isSelected[index]!;
    });
  }

  // Delete all files marked for deletion
  void deleteFiles() {
    var viewModel = context.read<StorageViewModel>();
    viewModel.bulkDeleteFiles();

    closeSelectionMode();
  }

  void closeSelectionMode() {
    setState(() {
      context.read<StorageViewModel>().clearSelection();
      isSelected.clear();
      selectionMode = false;
    });
  }

  /// Failure: -1, Success: 0, No rename done: 1
  Future<int> renameFile(String newFileName) async {
    var viewModel = context.read<StorageViewModel>();
    int ret;
    try {
      int index = viewModel.isOneFileSelected(isSelected);
      if (index == -1) throw "Index out of bound";
      var fileName = viewModel.userDocuments[index];
      ret = await viewModel.renameFile(p.basename(fileName.path), newFileName);
    } catch (e) {
      debugPrint("Error HomePage renameFile: $e");
      return -1;
    }
    return ret;
  }

  void _showSnackBar(String msg) {
    var snackBar = SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 1),
      action: SnackBarAction(
        label: "Dismiss",
        onPressed: () => ScaffoldMessenger.of(context).removeCurrentSnackBar(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _renameFileAlertDialog(BuildContext context) async {
    bool isError = false;
    var viewModel = context.read<StorageViewModel>();
    final textController = TextEditingController();
    int index = viewModel.isOneFileSelected(isSelected);
    // Don't show alert dialog if more than one element selected
    if (index == -1) {
      _showSnackBar("Only one file can be renamed!");
    }
    String prevName = p.basename(viewModel.userDocuments[index].path);
    textController.text = prevName;

    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(AppStrings.renameFileTitle),
        content: TextField(
          controller: textController,
          onChanged: (_) => isError = true,
          decoration: InputDecoration(
            labelText: "Enter FileName",
            // Does not actually work dynamically
            errorText: isError ? "Filename already exists!" : null,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(AppStrings.cancel)),
          TextButton(
              onPressed: () async {
                int success = await renameFile(textController.text);
                if (context.mounted) {
                  if (success == 1) {
                    isError = true;
                    _showSnackBar("Filename already exists!");
                    return;
                  }
                  Navigator.pop(context);
                  closeSelectionMode();

                  if (success == 0) {
                    _showSnackBar(
                        "Renamed $prevName to ${textController.text}");
                  } else {
                    debugPrint("Something went wrong with rename alert dialog");
                  }
                }
              },
              child: const Text(AppStrings.renameFile)),
        ],
      ),
    );
  }
}

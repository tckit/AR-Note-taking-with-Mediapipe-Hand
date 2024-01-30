import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_app/connector/FlutterKotlin.dart';
import 'package:my_app/provider/homepage_provider.dart';
import 'package:my_app/ui/folder_tree_page.dart';
import 'package:my_app/viewModel/storage_view_model.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

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
    var viewModel = context.watch<StorageViewModel>();
    bool isHomepage = viewModel.isHomePage();

    return AppBar(
      leading: _buildTopLeftIcon(isHomepage),
      title: Text(isHomepage
          ? AppStrings.appTitle
          : p.basename(viewModel.currentDirectoryPath)),
      centerTitle: true,
      actions: [
        if (selectionMode)
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: shareFiles,
          ),
        Consumer<HomePageProvider>(builder: (_, provider, __) {
          if (provider.bottomNavBarIndex == 0) {
            return IconButton(
              icon: const Icon(Icons.grid_view_rounded),
              selectedIcon: const Icon(Icons.list_rounded),
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
      return Column(children: <Widget>[
        Text('Failed to build. Index: $currentIndex'),
      ]);
    } else {
      return Center(
        child: Text('Unable to build body. Index: $currentIndex'),
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
    final documents = viewModel.getUserDocuments;

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
                onPressed: () => onTapFile(index, isDirectory),
              ),
            ));
      },
    );
  }

  ListView _buildListView(StorageViewModel viewModel) {
    final documents = viewModel.getUserDocuments;

    return ListView.builder(
        itemCount: documents.length,
        itemBuilder: (_, int index) {
          // initialize isSelected with false
          isSelected[index] = isSelected[index] ?? false;
          String currentFilePath = documents[index].path;
          bool isDirectory = viewModel.isDirectory(currentFilePath);

          return ListTile(
            onLongPress: () => onLongPressFile(index, isDirectory),
            onTap: () => onTapFile(index, isDirectory),
            title: Row(
              children: [
                isDirectory
                    ? const Icon(Icons.folder)
                    : const Icon(Icons.image),
                const SizedBox(width: 10),
                // fileName
                documents.isEmpty
                    ? Text("Desc")
                    : Text(p.basename(currentFilePath)),
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

  /// if selectionMode, allow user to exit
  ///
  /// if user is at homepage, user can visit FolderTreePage
  ///
  /// if user is using search bar, show nothing here
  ///
  /// if user is not on homepage & not using search bar, allow user to return
  Widget _buildTopLeftIcon(bool isHomePage) {
    bool isSearching = context.select((HomePageProvider p) => p.isSearching);

    return selectionMode
        ? IconButton(
            icon: const Icon(Icons.close),
            onPressed: closeSelectionMode,
          )
        : isHomePage
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FolderTreePage())),
              )
            : isSearching
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.chevron_left_sharp),
                    onPressed: redirectBack,
                  );
  }

  Widget _buildTopRightIcons() {
    return Consumer<HomePageProvider>(builder: (_, provider, __) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (provider.isSearching) _buildSearchBar(),
          IconButton(
            onPressed: () {
              provider.toggleSearchBar();
              if (!provider.isSearching) {
                resetViewToDefault();
              }
            },
            icon: const Icon(Icons.search),
            tooltip: 'Search',
          ),
          IconButton(
            onPressed: () {
              provider.toggleSortFiles();
              sortFiles(provider);
            },
            icon: const Icon(Icons.sort_by_alpha),
            tooltip: 'Order A-Z / Z-A',
          ),
        ],
      );
    });
  }

  Widget _buildSelectionTopRightIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
            onPressed: () => _renameFileAlertDialog(context),
            icon: const Icon(Icons.drive_file_rename_outline_rounded)),
        IconButton(onPressed: deleteFiles, icon: const Icon(Icons.delete)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: SearchBar(
          onChanged: (text) => searchFiles(text),
          constraints: const BoxConstraints(),
        ),
      ),
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
      addOrRemoveSelectedFiles(index);
    } else if (isDirectory) {
      viewModel.goToNextDirectory(index);
    } else {
      await viewModel.setPrefsForUnity(index);
      connector?.callKotlin();
      await viewModel.testPrefs();
    }
  }

  void redirectBack() {
    context.read<StorageViewModel>().goToPrevDirectory();
  }

  /// Mark files as selected or vice-versa for further actions
  void addOrRemoveSelectedFiles(int index) {
    var viewModel = context.read<StorageViewModel>();
    viewModel.addOrRemoveSelectedFiles(index);

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

  void shareFiles() async {
    final box = context.findRenderObject() as RenderBox?;

    var viewModel = context.read<StorageViewModel>();
    final success = await viewModel.shareFiles(box);
    if (success) {
      closeSelectionMode();
    }
  }

  void closeSelectionMode() {
    setState(() {
      context.read<StorageViewModel>().clearSelection();
      isSelected.clear();
      selectionMode = false;
    });
  }

  void searchFiles(String fileName) {
    var viewModel = context.read<StorageViewModel>();
    var documentsReturned = viewModel.searchFiles(fileName);

    var provider = context.read<HomePageProvider>();
    if (provider.isSearching) {
      viewModel.getTemporaryView(documentsReturned);
    } else {
      resetViewToDefault();
    }
  }

  void sortFiles(HomePageProvider provider) {
    var viewModel = context.read<StorageViewModel>();
    viewModel.sortAndUpdateUI(provider.isAscending);
  }

  /// Reset to default view before any search happens
  void resetViewToDefault() {
    var viewModel = context.read<StorageViewModel>();
    viewModel.removeTemporaryView();
  }

  /// Failure: -1, Success: 0, No rename done: 1
  Future<int> renameFile(String newFileName) async {
    var viewModel = context.read<StorageViewModel>();
    int ret;
    try {
      int index = viewModel.isOneFileSelected(isSelected);
      if (index == -1) throw "Index out of bound";

      var fileName = viewModel.getUserDocuments[index];
      if (viewModel.isDirectory(fileName.path)) {
        ret = await viewModel.renameDirectory(fileName.path, newFileName);
      } else {
        ret = await viewModel.renameFile(fileName.path, newFileName);
      }
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
    String prevName = p.basename(viewModel.getUserDocuments[index].path);
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

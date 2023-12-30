import 'package:flutter/material.dart';
import 'package:my_app/viewModel/storage_view_model.dart';
import 'package:provider/provider.dart';
import 'package:my_app/provider/page_selector_provider.dart';
import 'package:my_app/strings/strings.dart';
import 'package:my_app/ui/homepage.dart';
import 'package:my_app/ui/settings_page.dart';
import 'package:my_app/ui/widget/app_bottom_navigation_bar.dart';

class PageSelector extends StatelessWidget {
  const PageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("Executing PageSelector");
    return WillPopScope(
      onWillPop: () => _showExitPopup(context),
      child: Scaffold(
        body: Column(
          children: [
            Expanded(child: _buildBody()),
            _buildAddFilesButton(context)
          ],
        ),
        // _buildBody(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildFloatingActionButton(context),
        bottomNavigationBar: _buildAppBottomNavigationBar(),
      ),
    );
  }

  /// Display text for importing/adding files/folders
  Widget _buildAddFilesButton(BuildContext context) {
    return Consumer<PageSelectorProvider>(
      builder: (_, provider, child) {
        if (provider.clickedAddActionButton) {
          return Container(
            child: child,
          );
        }
        return const SizedBox.shrink();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextButton(
                  onPressed: () => createDirectory(context),
                  child: const Text("Create new folder")),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextButton(
                onPressed: () {
                  // Create file in image format
                  // final viewModel = context.read<StorageViewModel>();
                  // viewModel.createFile();
                },
                child: const Text("Create new files")),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextButton(
                onPressed: () => importFiles(context),
                child: const Text("Import files"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<PageSelectorProvider>(
      builder: (context, provider, __) {
        debugPrint("Current Page: ${provider.pageName}");
        switch (provider.pageName) {
          case Pages.homePage:
            return HomePage();
          case Pages.settingsPage:
            return SettingsPage();
          default:
            debugPrint("Cannot find page to navigate");
        }
        return const Center(
          child: Row(children: [Text("No pages found")]),
        );
      },
    );
  }

  /// Add button for files, for calling _buildAddFilesButton
  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      backgroundColor: Colors.lightBlue,
      onPressed: () =>
          context.read<PageSelectorProvider>().toggleClickActionButton(),
      child: const Icon(Icons.add),
    );
  }

  Widget _buildAppBottomNavigationBar() {
    return const AppBottomNavigationBar();
  }

  Future<bool> _showExitPopup(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.exitApp),
        content: const Text(AppStrings.doYouWantToExitApp),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.exit),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String msg) {
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

  void importFiles(BuildContext context) async {
    final viewModel = context.read<StorageViewModel>();
    var file = await viewModel.importFile();
    if (file != null && context.mounted) {
      context
          .read<PageSelectorProvider>()
          .toggleClickActionButton();

      _showSnackBar(context, "Imported ${file.fileName} successfully");
    }
  }

  void createDirectory(BuildContext context) async {
    final viewModel = context.read<StorageViewModel>();
    bool success = await viewModel.createDirectory(viewModel.currentDirectoryPath);
    if (success && context.mounted) {
      context
          .read<PageSelectorProvider>()
          .toggleClickActionButton();

      _showSnackBar(context, "Created directory");
    }
  }
}

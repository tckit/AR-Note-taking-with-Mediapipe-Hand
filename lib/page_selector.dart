import 'package:flutter/material.dart';
import 'package:my_app/provider/homepage_provider.dart';
import 'package:my_app/provider/page_selector_provider.dart';
import 'package:my_app/strings/strings.dart';
import 'package:my_app/ui/homepage.dart';
import 'package:my_app/ui/settings_page.dart';
import 'package:my_app/ui/widget/add_files_bottom_menu.dart';
import 'package:my_app/ui/widget/app_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';

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
            AddFilesBottomMenu(
                showSnackBar: _showSnackBar,
                closeFloatingActionMenu: _closeFloatingActionMenu
            )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildFloatingActionButton(context),
        bottomNavigationBar: _buildAppBottomNavigationBar(),
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<PageSelectorProvider>(
      builder: (context, provider, __) {
        debugPrint("Current Page: ${provider.pageName}");
        switch (provider.pageName) {
          case Pages.homePage:
            context.read<HomePageProvider>().resetState();
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
          _closeFloatingActionMenu(context),
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

  void _closeFloatingActionMenu(BuildContext context) {
    context
        .read<PageSelectorProvider>()
        .toggleClickActionButton();
  }
}

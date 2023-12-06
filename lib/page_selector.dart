import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/provider/homepage_provider.dart';
import 'package:untitled_app/provider/page_selector_provider.dart';
import 'package:untitled_app/strings/strings.dart';
import 'package:untitled_app/ui/homepage.dart';
import 'package:untitled_app/ui/settings_page.dart';
import 'package:untitled_app/ui/widget/app_bottom_navigation_bar.dart';

class PageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint("Executing PageSelector");
    return WillPopScope(
      onWillPop: () => _showExitPopup(context),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _buildAppBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<PageSelectorProvider>(
      builder: (_, provider, __) {
        switch (provider.pageName) {
          case Pages.homePage:
            return HomePage();
            break;
          case Pages.settingsPage:
            return SettingsPage();
            break;
          default:
            debugPrint("Cannot find page to navigate");
        }
        return const Center(
          child: Row(children: [Text("No pages found")]),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Icon(Icons.menu),
      title: Text(AppStrings.appTitle),
      centerTitle: true,
      actions: [
        Consumer<HomePageProvider>(builder: (_, provider, __) {
          if (provider.bottomNavBarIndex == 0) {
            return IconButton(
              icon: Icon(Icons.grid_view_rounded),
              selectedIcon: Icon(Icons.list_rounded),
              isSelected: provider.isGridView(),
              tooltip: 'Add button here',
              onPressed: () => provider.toggleHomePageView(),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
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
}

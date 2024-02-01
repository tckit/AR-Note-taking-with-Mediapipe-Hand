import 'package:flutter/material.dart';

enum Pages {
  homePage,
  settingsPage,
}

class PageSelectorProvider with ChangeNotifier {
  Pages _pageName = Pages.homePage;
  bool _clickedAddActionButton = false;

  Pages get pageName => _pageName;

  bool get clickedAddActionButton => _clickedAddActionButton;

  set pageName(Pages newPageName) {
    _pageName = newPageName;
    notifyListeners();
  }

  set clickedAddActionButton(bool clicked) {
    _clickedAddActionButton = clicked;
    notifyListeners();
  }

  void toggleClickActionButton() {
    clickedAddActionButton = !clickedAddActionButton;
  }
}

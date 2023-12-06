import 'package:flutter/material.dart';

enum Pages {
  homePage,
  settingsPage,
}

class PageSelectorProvider with ChangeNotifier {
  Pages _pageName = Pages.homePage;

  Pages get pageName => _pageName;

  set pageName(Pages newPageName) {
    _pageName = newPageName;
    notifyListeners();
  }
}
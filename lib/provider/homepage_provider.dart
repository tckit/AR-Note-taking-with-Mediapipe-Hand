import 'package:flutter/material.dart';

enum ViewTypes { grid, list }

class HomePageProvider with ChangeNotifier {
  ViewTypes _homePageView = ViewTypes.grid;
  int _bottomNavBarIndex = 0;
  int _prevNavBarIndex = 0;

  int get bottomNavBarIndex => _bottomNavBarIndex;
  int get prevNavBarIndex => _prevNavBarIndex;

  ViewTypes get homePageView => _homePageView;

  set bottomNavBarIndex(int index) {
    _prevNavBarIndex = _bottomNavBarIndex;
    _bottomNavBarIndex = index;
    notifyListeners();
  }

  void toggleHomePageView() {
    _homePageView = (_homePageView == ViewTypes.grid)
        ? ViewTypes.list
        : ViewTypes.grid;
    notifyListeners();
  }

  bool isGridView() {
    return _homePageView == ViewTypes.grid;
  }

  void selectBottomNavBar(int index) {
    _prevNavBarIndex = _bottomNavBarIndex;
    _bottomNavBarIndex = index;
    notifyListeners();
  }

  void popReverseNavBarIndex() {
    if (_bottomNavBarIndex != _prevNavBarIndex) {
      _bottomNavBarIndex = _prevNavBarIndex;
      notifyListeners();
    }
  }
}

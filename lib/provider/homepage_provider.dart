import 'package:flutter/material.dart';

enum ViewTypes { grid, list }

class HomePageProvider with ChangeNotifier {
  ViewTypes _homePageView = ViewTypes.grid;
  int _bottomNavBarIndex = 0;
  int _prevNavBarIndex = 0;
  bool _isAscending = true;
  bool _isSearching = false;

  int get bottomNavBarIndex => _bottomNavBarIndex;
  int get prevNavBarIndex => _prevNavBarIndex;

  bool get isAscending => _isAscending;
  bool get isSearching => _isSearching;

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

  void toggleSortFiles() {
    _isAscending = !_isAscending;
    notifyListeners();
  }

  void toggleSearchBar() {
    _isSearching = !_isSearching;
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

  void resetState() {
    _isSearching = false;
  }
}

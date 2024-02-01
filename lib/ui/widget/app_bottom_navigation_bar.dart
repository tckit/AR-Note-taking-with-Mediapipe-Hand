import 'package:flutter/material.dart';
import 'package:my_app/provider/homepage_provider.dart';
import 'package:my_app/provider/page_selector_provider.dart';
import 'package:my_app/strings/strings.dart';
import 'package:provider/provider.dart';

@immutable
class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final int currentIndex = context
        .select((HomePageProvider provider) => provider.bottomNavBarIndex);
    debugPrint('building AppBottomNavigationBar');
    debugPrint('Index for BottomNavBar $currentIndex');

    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: AppStrings.home,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: AppStrings.setting,
        ),
      ],
      currentIndex: currentIndex,
      onTap: (index) {
        context.read<HomePageProvider>().selectBottomNavBar(index);
        context.read<PageSelectorProvider>().pageName = Pages.values[index];
      },
    );
  }
}

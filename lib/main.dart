import 'package:flutter/material.dart';
import 'package:my_app/viewModel/storage_view_model.dart';
import 'package:provider/provider.dart';
import 'package:my_app/page_selector.dart';
import 'package:my_app/provider/homepage_provider.dart';
import 'package:my_app/provider/page_selector_provider.dart';
import 'strings/strings.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomePageProvider>(
            create: (_) => HomePageProvider()
        ),
        ChangeNotifierProvider<PageSelectorProvider>(
            create: (_) => PageSelectorProvider()
        ),
        ChangeNotifierProvider<StorageViewModel>(
            create: (_) => StorageViewModel()
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue.shade300,
          ),
        ),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: ThemeMode.system,
        home: PageSelector(),
      ),
    );
  }
}

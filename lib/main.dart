import 'package:flutter/material.dart';
import 'package:my_app/page_selector.dart';
import 'package:my_app/provider/homepage_provider.dart';
import 'package:my_app/provider/page_selector_provider.dart';
import 'package:my_app/provider/settings_provider.dart';
import 'package:my_app/provider/theme_provider.dart';
import 'package:my_app/viewModel/storage_view_model.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<HomePageProvider>(
              create: (_) => HomePageProvider()),
          ChangeNotifierProvider<PageSelectorProvider>(
              create: (_) => PageSelectorProvider()),
          ChangeNotifierProvider<SettingsProvider>(
              create: (_) => SettingsProvider()),
          ChangeNotifierProvider<StorageViewModel>(
              create: (_) => StorageViewModel()),
        ],
        child: Consumer<ThemeProvider>(
          builder: (_, provider, __) {
            return MaterialApp(
              theme: ThemeData(
                useMaterial3: true,
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.blue.shade300,
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.blue.shade900,
                ),
              ),
              themeMode: provider.themeMode,
              home: PageSelector(),
            );
          },
        ));
  }
}

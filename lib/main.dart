import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/page_selector.dart';
import 'package:untitled_app/provider/homepage_provider.dart';
import 'package:untitled_app/provider/page_selector_provider.dart';
import 'package:untitled_app/ui/homepage.dart';
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

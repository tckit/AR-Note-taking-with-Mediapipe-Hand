import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/provider/homepage_provider.dart';
import 'package:my_app/strings/strings.dart';
import 'package:my_app/ui/widget/app_bottom_navigation_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("building SettingsPage");
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[Text('data')],
      ),
    );
  }
}

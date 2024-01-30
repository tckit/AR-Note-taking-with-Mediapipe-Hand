import 'package:flutter/material.dart';
import 'package:my_app/provider/settings_provider.dart';
import 'package:my_app/provider/theme_provider.dart';
import 'package:my_app/strings/strings.dart';
import 'package:provider/provider.dart';

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
        children: <Widget>[
          _buildProfile(),
          _buildSettingsRow(),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildProfile() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 80),
      child: const CircleAvatar(
        backgroundColor: Colors.lightBlueAccent,
        radius: 100,
        child: Icon(
          Icons.person_outline,
          size: 150,
        ),
      ),
    );
  }

  Widget _buildSettingsRow() {
    return Consumer<SettingsProvider>(builder: (context, provider, __) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.only(top: 80),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ListTile(
                leading: Text("Dark Mode", textScaleFactor: 1.2),
                trailing: Switch.adaptive(
                  value: provider.isDarkMode,
                  onChanged: (value) =>
                      _switchLightOrDarkMode(context, provider, value),
                ),
                shape: Border(top: BorderSide(), bottom: BorderSide()),
                onTap: () {},
              ),
              ListTile(
                leading: Text(
                  "AR mode",
                  textScaleFactor: 1.2,
                ),
                trailing: Switch.adaptive(
                  value: provider.isArMode,
                  onChanged: (value) => _switchARMode(context, provider, value),
                ),
                shape: Border(bottom: BorderSide()),
                onTap: () {},
              ),
            ],
          ),
        ),
      );
    });
  }

  void _switchLightOrDarkMode(
      BuildContext context, SettingsProvider provider, bool value) {
    provider.isDarkMode = value;

    context.read<ThemeProvider>().toggleThemeMode();
  }

  void _switchARMode(
      BuildContext context, SettingsProvider provider, bool value) {
    provider.isArMode = value;

  }
}

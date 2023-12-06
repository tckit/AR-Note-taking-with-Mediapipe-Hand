import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/provider/homepage_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    var provider = context.read<HomePageProvider>();
    provider.bottomNavBarIndex = 0;
    debugPrint("building HomePage init");
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("building HomePage");
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final currentIndex = context.watch<HomePageProvider>().bottomNavBarIndex;

    if (currentIndex == 0) {
      return Column(children: <Widget>[
        _buildTopRightIcons(),
        Expanded(child: _selectGridOrListView()),
      ]);
    } else if (currentIndex == 1) {
      return const Column(children: <Widget>[
        Text('data'),
      ]);
    } else {
      return const Center(
        child: Text('Unable to build body'),
      );
    }
  }

  Widget _selectGridOrListView() {
    // Try selector
    return Consumer<HomePageProvider>(
      builder: (_, provider, __) {
        if (provider.homePageView == ViewTypes.grid) {
          return _buildGridView(provider);
        }
        return _buildListView(provider);
      },
    );
  }

  GridView _buildGridView(HomePageProvider provider) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: provider.userFiles.length + 4,
      itemBuilder: (_, int index) {
        return InkWell(
          onTap: null,
          onLongPress: null,
          child: GridTile(
            footer: Center(
              child: Text("Desc"),
            ),
            child: IconButton(
              icon: Icon(Icons.photo),
              iconSize: 100,
              onPressed: test,
            ),
          ),
        );
      },
    );
  }


  Future<void> test() async {
    const platform = MethodChannel("kotlin/helper");
    try {
      String res = await platform.invokeMethod("test", {
        "testvar": "string of var"
      });
      debugPrint("Called kotlin function $res");
    } on PlatformException catch (e) {
      debugPrint("Cannot call kotlin function");
    }
  }

  ListView _buildListView(HomePageProvider provider) {
    return ListView.builder(
      itemCount: provider.userFiles.length + 4,
      itemBuilder: (_, int index) {
        return ListTile(
          onTap: null,
          onLongPress: null,
          leading: Icon(Icons.chevron_right),
          title: Text('listTile $index'),
        );
      },
    );
  }

  Widget _buildTopRightIcons() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <IconButton>[
        IconButton(
          onPressed: null,
          icon: Icon(Icons.search),
          tooltip: 'Add button here',
        ),
        IconButton(
          onPressed: null,
          icon: Icon(Icons.sort_by_alpha),
          tooltip: 'Add button here',
        ),
        IconButton(
          onPressed: null,
          icon: Icon(Icons.filter_alt),
          tooltip: 'Add button here',
        ),
      ],
    );
  }
}

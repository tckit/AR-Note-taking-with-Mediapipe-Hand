import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class FlutterKotlin {
  Future<void> callKotlin() async {
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
}
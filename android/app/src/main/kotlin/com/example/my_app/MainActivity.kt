package com.example.my_app

import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val channel = "kotlin/helper"
    private val tag = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler{
            call, result ->
            when {
                call.method.equals("test") -> {
                    Log.w(tag, "Calling test...")
                    test(call, result)
                }
                call.method.equals("callUnity") -> {
                    Log.w(tag, "Calling Unity...")
                    callUnity()
                }
                else -> Log.w(tag, "Failed to call kotlin")
            }
        }
    }

    private fun test(call: MethodCall, result: MethodChannel.Result) {
        Log.w(tag, "Entered test function")
        return result.success(call.argument<String>("testVar"))
    }

    private fun callUnity() {
//        val intent = Intent(this, UnityPlayerActivity::class.java)
        Log.d(tag, "Calling UnityPlayer")
        val intent = Intent(this, UnityAdapter::class.java)
        startActivity(intent)
    }
}

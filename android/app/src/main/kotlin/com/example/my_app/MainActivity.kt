package com.example.my_app

import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val channel = "kotlin/helper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler{
            call, result ->
            when {
                call.method.equals("test") -> {
                    Log.w("MainActivity", "Calling test...")
                    test(call, result)
                }
                else -> Log.w("MainActivity", "Failed to call kotlin")
            }
        }
    }

    fun test(call: MethodCall, result: MethodChannel.Result) {
        Log.w("MainActivity", "Entered test function");
        return result.success(call.argument<String>("testvar"));
    }

    fun callUnity() {
//        val intent = Intent(this, UnityPlayerActivity::class.java)
//        startActivity(intent)
    }
}
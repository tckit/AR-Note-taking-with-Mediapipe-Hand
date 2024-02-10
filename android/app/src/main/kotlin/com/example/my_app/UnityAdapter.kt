package com.example.my_app

import android.content.SharedPreferences
import android.os.Bundle
import android.util.Log
import com.example.my_app.data.SceneNameKey
import com.example.my_app.data.SharedPrefKey
import com.unity3d.player.UnityPlayer
import com.unity3d.player.UnityPlayerActivity

class UnityAdapter : UnityPlayerActivity() {
    private val sharedPref: SharedPreferences by lazy {
        getSharedPreferences(SharedPrefKey.prefName, MODE_PRIVATE)
    }

    private val tag = "UnityAdapter"
    private var arMode: Boolean = true

    private val gameObjectName: String = "LoadNextLevel"
    private val methodName: String = "LoadSceneName"

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.d("UnityAdapter", "Creating UnityPlayer")
        super.onCreate(savedInstanceState)

        arMode = getArFlag()
        Log.w(tag, "arMode value: $arMode")
        val sceneName: String = if (arMode) SceneNameKey.arMode else SceneNameKey.nonArMode
        UnityPlayer.UnitySendMessage("LoadNextLevel", "LoadSceneName", sceneName)
    }

    private fun getArFlag(): Boolean {
        return sharedPref.getBoolean(SharedPrefKey.arMode, true)
    }

    private fun sendMessageToUnity(message: String) {
        UnityPlayer.UnitySendMessage(gameObjectName, methodName, message)
    }

    private fun getCurrentDirectoryPath(): String? {
        return sharedPref.getString(SharedPrefKey.currentDirectoryPath, null)
    }

    private fun getUserChosenFilePath(): String? {
        return sharedPref.getString(SharedPrefKey.userChosenFilePath, null)
    }

    private fun getPdfDirectoryPath(): String? {
        return sharedPref.getString(SharedPrefKey.directoryPathForPdf, null)
    }

    override fun onUnityPlayerUnloaded() {
        super.onUnityPlayerUnloaded()
    }

    override fun onUnityPlayerQuitted() {
        super.onUnityPlayerQuitted()
    }
}
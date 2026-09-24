package com.example.foap

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "facehub/settings"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "openNetworkSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_WIRELESS_SETTINGS)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error(
                            "SETTINGS_ERROR",
                            "Could not open network settings",
                            e.message
                        )
                    }
                }

                "openSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_SETTINGS)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error(
                            "SETTINGS_ERROR",
                            "Could not open Android settings",
                            e.message
                        )
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
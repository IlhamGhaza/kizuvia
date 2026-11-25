package com.igz.kizuvia

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kizuvia/system")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // "Do Not Disturb access": lets the alarm channel bypass DND.
                    "dndAccessGranted" -> result.success(nm.isNotificationPolicyAccessGranted)
                    "openDndAccess" -> {
                        startActivity(Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS))
                        result.success(null)
                    }
                    // Android 14+: full-screen intents need a user grant.
                    "fullScreenIntentAllowed" ->
                        result.success(
                            if (Build.VERSION.SDK_INT >= 34) nm.canUseFullScreenIntent() else true
                        )
                    "openFullScreenIntentSettings" -> {
                        if (Build.VERSION.SDK_INT >= 34) {
                            startActivity(
                                Intent(
                                    Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT,
                                    Uri.parse("package:$packageName")
                                )
                            )
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}

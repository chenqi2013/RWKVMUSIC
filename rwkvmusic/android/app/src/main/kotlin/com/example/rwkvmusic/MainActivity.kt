package com.example.rwkvmusic

import io.flutter.embedding.android.FlutterActivity

import android.os.Build
import android.os.Build.VERSION_CODES
import androidx.annotation.NonNull
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.cpu_info"

    /*
    override fun configureFlutterEngine() {
        super.configureFlutterEngine()
        MethodChannel(flutterEngine?.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getProcessorModel") {
                result.success(getProcessorModel())
            } else {
                result.notImplemented()
            }
        }
    }
    */

    private fun getProcessorModel(): String {
        return try {
            // 获取当前设备的 CPU ABI（通常是 arm64-v8a, armeabi-v7a, x86_64 等）
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                Build.SUPPORTED_ABIS.joinToString(", ")  // 获取 CPU 架构
            } else {
                Build.CPU_ABI  // 旧版本设备获取 CPU ABI
            }
        } catch (e: Exception) {
            "Unknown Processor"
        }
    }
}

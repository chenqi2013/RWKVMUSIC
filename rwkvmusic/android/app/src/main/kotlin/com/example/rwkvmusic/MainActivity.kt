package com.example.rwkvmusic

import android.content.res.AssetManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {

  private lateinit var methodChannel: MethodChannel
  private lateinit var assetManager: AssetManager

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    assetManager = createPackageContext(context.packageName, 0).assets
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "universal")
    methodChannel.setMethodCallHandler(this::methodCallHandler)
  }

  /**
   * Checks if the file exists in the cache.
   *
   * If not, retrieves it from the bundle and copies it to the cache.
   *
   * @return The path of the file in the cache.
   */
  private fun copyAssetToFile(assetName: String): String {
    val file = File(context.cacheDir, assetName)
    val exists = file.exists()
    if (exists) println("file exists in cache: $assetName")
    if (!exists) println("file not exists in cache: $assetName")
    if (exists) return file.absolutePath

    val assetStream = assetManager.open(assetName)

    assetStream.use { i ->
      FileOutputStream(file).use { o ->
        i.copyTo(o)
      }
    }

    return file.absolutePath
  }

  private fun methodCallHandler(call: MethodCall, result: MethodChannel.Result) {
    val method = call.method
    val args = call.arguments as Map<*, *>
    when (method) {
      "getAssetPath" -> {
        try {
          val assetName = args["assetName"] as String
          val path = copyAssetToFile(assetName)
          result.success(path)
        } catch (e: Exception) {
          result.error(e.message ?: "", e.localizedMessage ?: "", e)
        }
      }

      "listAllAssets" -> {
        try {
          val path = args["path"] as String
          val list = assetManager.list(path)?.toList()
          result.success(list)
        } catch (e: Exception) {
          e.printStackTrace()
        }
      }

      else -> result.notImplemented()
    }
  }


}

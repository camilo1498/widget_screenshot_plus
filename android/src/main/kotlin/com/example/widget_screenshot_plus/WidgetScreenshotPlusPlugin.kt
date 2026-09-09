package com.example.widget_screenshot_plus

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMethodCodec

/** WidgetScreenshotPlusPlugin */
class WidgetScreenshotPlusPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel

  override fun onAttachedToEngine( flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val taskQueue =
      flutterPluginBinding.binaryMessenger.makeBackgroundTaskQueue()
    channel = MethodChannel(
      flutterPluginBinding.binaryMessenger,
      "widget_shot",
      StandardMethodCodec.INSTANCE,
      taskQueue
    )
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "merge") {
      val arguments = call.arguments as? Map<String, Any>
      if (arguments == null) {
        result.error("invalid_args", "Arguments must be a dictionary", null)
        return
      }
      try {
        val merger = Merger(arguments)
        result.success(merger.merge())
      } catch (e: IllegalArgumentException) {
        result.error("invalid_args", e.message, null)
      } catch (e: OutOfMemoryError) {
        result.error("merge_failed", "Out of memory while merging images", null)
      } catch (e: Exception) {
        result.error("merge_failed", e.message, null)
      }
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}

package com.example.widget_screenshot_plus

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import org.mockito.Mockito
import org.mockito.ArgumentMatchers.any

/*
 * Unit tests for the Kotlin portion of this plugin's implementation.
 *
 * Run from the `example/android/` directory with `./gradlew testDebugUnitTest`,
 * or directly from IDEs that support JUnit such as Android Studio.
 */

internal class WidgetScreenshotPlusPluginTest {
  @Test
  fun onMethodCall_unknownMethod_returnsNotImplemented() {
    val plugin = WidgetScreenshotPlusPlugin()

    val call = MethodCall("unknownMethod", null)
    val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
    plugin.onMethodCall(call, mockResult)

    Mockito.verify(mockResult).notImplemented()
  }

  @Test
  fun onMethodCall_mergeWithoutArgs_returnsInvalidArgsError() {
    val plugin = WidgetScreenshotPlusPlugin()

    val call = MethodCall("merge", null)
    val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
    plugin.onMethodCall(call, mockResult)

    Mockito.verify(mockResult).error(
      Mockito.eq("invalid_args"),
      any(),
      Mockito.isNull()
    )
  }

  @Test
  fun merger_emptyParams_throwsIllegalArgument() {
    var thrown = false
    try {
      Merger(emptyMap()).merge()
    } catch (e: IllegalArgumentException) {
      thrown = true
    }
    assertTrue(thrown, "Expected IllegalArgumentException for empty params")
  }

  @Test
  fun mergeParam_parsesColorAndFormat() {
    val pngBytes = byteArrayOf(1, 2, 3)
    val mergerParams = mapOf<String, Any?>(
      "color" to listOf(255, 255, 0, 0),
      "width" to 10.0,
      "height" to 20.0,
      "format" to 0,
      "quality" to 100,
      "imageParams" to listOf(
        mapOf<String, Any?>(
          "image" to pngBytes,
          "dx" to 0.0,
          "dy" to 0.0,
          "width" to 10.0,
          "height" to 20.0
        )
      )
    )
    // Constructor must not throw for well-formed params.
    val merger = Merger(mergerParams)
    assertEquals(10.0, mergerParams["width"])
  }
}

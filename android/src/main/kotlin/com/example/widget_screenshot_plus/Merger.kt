package com.example.widget_screenshot_plus

import android.graphics.*
import java.io.ByteArrayOutputStream
import androidx.core.graphics.createBitmap

class Merger(param: Map<String, Any?>) {
    private val mergeParam: MergeParam

    // Robust conversion helpers
    private fun toInt(value: Any?): Int = when (value) {
        is Int -> value
        is Double -> value.toInt()
        is Float -> value.toInt()
        is Number -> value.toInt()
        is String -> value.toDoubleOrNull()?.toInt() ?: 0
        else -> 0 // Default to 0 if null or unknown type
    }
    private fun toDouble(value: Any?): Double = when (value) {
        is Double -> value
        is Int -> value.toDouble()
        is Float -> value.toDouble()
        is Number -> value.toDouble()
        is String -> value.toDoubleOrNull() ?: 0.0
        else -> 0.0 // Default to 0.0 if null or unknown type
    }

    init {
        val color = (param["color"] as? List<*>)?.map { toInt(it) }
        val width = toDouble(param["width"])
        val height = toDouble(param["height"])
        val format = toInt(param["format"])
        val quality = toInt(param["quality"])
        val imageParams = (param["imageParams"] as? List<*>)?.mapNotNull { item ->
            val map = item as? Map<*, *> ?: return@mapNotNull null
            val image = map["image"] as? ByteArray ?: return@mapNotNull null
            val dx = toDouble(map["dx"])
            val dy = toDouble(map["dy"])
            val width = toDouble(map["width"])
            val height = toDouble(map["height"])
            ImageParam(image, dx, dy, width, height)
        } ?: emptyList()
        mergeParam = MergeParam(
            if (color != null && color.size == 4) Color.argb(
                color[0], color[1], color[2], color[3]
            ) else null,
            width, height, format, quality, imageParams
        )
    }

    fun merge(): ByteArray {
        val resultBitmap = createBitmap(mergeParam.width.toInt(), mergeParam.height.toInt())
        val canvas = Canvas(resultBitmap)
        if (mergeParam.color != null) {
            canvas.drawColor(mergeParam.color)
        }
        mergeParam.imageParams.forEach {
            val image = BitmapFactory.decodeByteArray(it.image, 0, it.image.size)
            canvas.drawBitmap(
                image, null, RectF(
                    it.dx.toFloat(), it.dy.toFloat(),
                    (it.dx + it.width).toFloat(), (it.dy + it.height).toFloat()
                ), null
            )
        }
        val stream = ByteArrayOutputStream()
        val format: Bitmap.CompressFormat =
            if (mergeParam.format == FormatJPEG) Bitmap.CompressFormat.JPEG else Bitmap.CompressFormat.PNG
        resultBitmap.compress(format, mergeParam.quality, stream)
        return stream.toByteArray()
    }

}
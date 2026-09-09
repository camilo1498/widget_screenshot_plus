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
        val quality = toInt(param["quality"]).coerceIn(0, 100)
        val imageParams = (param["imageParams"] as? List<*>)?.mapNotNull { item ->
            val map = item as? Map<*, *> ?: return@mapNotNull null
            val image = map["image"] as? ByteArray ?: return@mapNotNull null
            if (image.isEmpty()) return@mapNotNull null
            val dx = toDouble(map["dx"])
            val dy = toDouble(map["dy"])
            val width = toDouble(map["width"])
            val height = toDouble(map["height"])
            if (width <= 0 || height <= 0) return@mapNotNull null
            ImageParam(image, dx, dy, width, height)
        } ?: emptyList()
        mergeParam = MergeParam(
            if (color != null && color.size == 4) Color.argb(
                color[0].coerceIn(0, 255),
                color[1].coerceIn(0, 255),
                color[2].coerceIn(0, 255),
                color[3].coerceIn(0, 255)
            ) else null,
            width, height, format, quality, imageParams
        )
    }

    fun merge(): ByteArray {
        val width = mergeParam.width.toInt()
        val height = mergeParam.height.toInt()
        require(width > 0 && height > 0) { "Invalid canvas size: ${width}x$height" }
        require(mergeParam.imageParams.isNotEmpty()) { "No images to merge" }
        // Guard against OOM on extremely tall scroll captures.
        val maxPixels = 16_000 * 16_000L
        require(width.toLong() * height.toLong() <= maxPixels) {
            "Canvas too large: ${width}x$height"
        }

        val resultBitmap = createBitmap(width, height)
        try {
            val canvas = Canvas(resultBitmap)
            if (mergeParam.color != null) {
                canvas.drawColor(mergeParam.color)
            }
            mergeParam.imageParams.forEach {
                val image = BitmapFactory.decodeByteArray(it.image, 0, it.image.size)
                    ?: return@forEach
                try {
                    canvas.drawBitmap(
                        image, null, RectF(
                            it.dx.toFloat(), it.dy.toFloat(),
                            (it.dx + it.width).toFloat(), (it.dy + it.height).toFloat()
                        ), null
                    )
                } finally {
                    if (!image.isRecycled) image.recycle()
                }
            }
            val stream = ByteArrayOutputStream()
            try {
                val format: Bitmap.CompressFormat =
                    if (mergeParam.format == FormatJPEG) Bitmap.CompressFormat.JPEG else Bitmap.CompressFormat.PNG
                // PNG ignores quality; JPEG uses 0-100.
                val quality = if (mergeParam.format == FormatJPEG) mergeParam.quality else 100
                if (!resultBitmap.compress(format, quality, stream)) {
                    throw IllegalStateException("Bitmap compression failed")
                }
                return stream.toByteArray()
            } finally {
                stream.close()
            }
        } finally {
            if (!resultBitmap.isRecycled) resultBitmap.recycle()
        }
    }
}

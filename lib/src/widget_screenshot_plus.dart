import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

import 'image_merger.dart';
import 'merge_param.dart';

export 'merge_param.dart' show ShotFormat;

/// A widget that enables screenshot functionality of its child.
///
/// Wraps its child in a RenderRepaintBoundary to capture its visual appearance.
class WidgetShotPlus extends SingleChildRenderObjectWidget {
  const WidgetShotPlus({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      WidgetShotPlusRenderRepaintBoundary(context);

  @override
  void updateRenderObject(
    BuildContext context,
    WidgetShotPlusRenderRepaintBoundary renderObject,
  ) {
    renderObject.context = context;
  }
}

/// The render object that handles the actual screenshot capture functionality.
class WidgetShotPlusRenderRepaintBoundary extends RenderRepaintBoundary {
  BuildContext context;

  WidgetShotPlusRenderRepaintBoundary(this.context);

  /// Captures a screenshot of the widget and any additional images.
  ///
  /// [scrollController] Used for capturing scrollable content (captures multiple screenshots)
  /// [extraImage] Additional images to include in the screenshot
  /// [maxHeight] Maximum height of the final image
  /// [pixelRatio] Device pixel ratio (defaults to screen's pixel ratio)
  /// [backgroundColor] Background color for the final image
  /// [format] Output image format (PNG or JPEG)
  /// [quality] Output quality (0-100) for JPEG format
  ///
  /// Returns the screenshot as bytes or null if capture fails.
  Future<Uint8List?> screenshot({
    ScrollController? scrollController,
    List<ImageParam> extraImage = const [],
    int maxHeight = 10000,
    double? pixelRatio,
    Color? backgroundColor,
    ShotFormat format = ShotFormat.png,
    int quality = 100,
  }) async {
    if (size.isEmpty || size.width <= 0 || size.height <= 0) {
      debugPrint('Error: RenderRepaintBoundary size is invalid: $size');
      return null;
    }

    final double effectivePixelRatio =
        pixelRatio ?? View.of(context).devicePixelRatio;
    final int effectiveQuality = quality.clamp(0, 100);

    double sHeight = size.height;
    if (scrollController != null &&
        scrollController.hasClients &&
        scrollController.position.hasViewportDimension) {
      final double viewport = scrollController.position.viewportDimension;
      if (viewport > 0) sHeight = viewport;
    }

    double imageHeight = 0;
    final imageParams = <ImageParam>[];

    // Add top extra images
    for (final e in extraImage.where((e) => e.offset == const Offset(-1, -1))) {
      imageParams.add(
        ImageParam(
          image: e.image,
          offset: Offset(0, imageHeight),
          size: e.size,
        ),
      );
      imageHeight += e.size.height;
    }

    final bool canScroll = scrollController != null &&
        scrollController.hasClients &&
        scrollController.position.maxScrollExtent > 0;

    if (canScroll) {
      scrollController.jumpTo(0);
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // First visible image
    final Uint8List firstImage = await _screenshot(effectivePixelRatio);
    imageParams.add(
      ImageParam(
        image: firstImage,
        offset: Offset(0, imageHeight),
        size: Size(size.width * effectivePixelRatio,
            size.height * effectivePixelRatio),
      ),
    );
    imageHeight += sHeight * effectivePixelRatio;

    if (canScroll) {
      int i = 1;
      while (imageHeight < maxHeight * effectivePixelRatio &&
          _canScroll(scrollController)) {
        final nextScroll = sHeight * i;
        final scrollExtent = scrollController.position.maxScrollExtent;

        if (scrollController.offset + sHeight / 10 > nextScroll) {
          scrollController.jumpTo(nextScroll);
          await Future.delayed(const Duration(milliseconds: 16));
          final img = await _screenshot(effectivePixelRatio);
          imageParams.add(
            ImageParam(
              image: img,
              offset: Offset(0, imageHeight),
              size: Size(size.width * effectivePixelRatio,
                  size.height * effectivePixelRatio),
            ),
          );
          imageHeight += sHeight * effectivePixelRatio;
          i++;
        } else if (nextScroll > scrollExtent) {
          final remainingHeight = scrollExtent + sHeight - sHeight * i;
          scrollController.jumpTo(scrollExtent);
          await Future.delayed(const Duration(milliseconds: 16));
          final img = await _screenshot(effectivePixelRatio);
          imageParams.add(
            ImageParam(
              image: img,
              offset: Offset(
                0,
                imageHeight -
                    ((size.height - remainingHeight) * effectivePixelRatio),
              ),
              size: Size(size.width * effectivePixelRatio,
                  size.height * effectivePixelRatio),
            ),
          );
          imageHeight += remainingHeight * effectivePixelRatio;
          break;
        } else {
          scrollController.jumpTo(scrollController.offset + sHeight / 10);
          await Future.delayed(const Duration(milliseconds: 16));
        }
      }
      // Restore scroll position after stitching.
      if (scrollController.hasClients) scrollController.jumpTo(0);
    }

    // Add bottom extra images
    for (final e in extraImage.where((e) => e.offset == const Offset(-2, -2))) {
      imageParams.add(
        ImageParam(
          image: e.image,
          offset: Offset(0, imageHeight),
          size: e.size,
        ),
      );
      imageHeight += e.size.height;
    }

    // Add manually positioned extra images
    for (final e in extraImage.where(
      (e) =>
          e.offset != const Offset(-1, -1) && e.offset != const Offset(-2, -2),
    )) {
      imageParams.add(e);
    }

    final mergeParam = MergeParam(
      color: backgroundColor,
      size: Size(size.width * effectivePixelRatio, imageHeight),
      format: format,
      quality: effectiveQuality,
      imageParams: imageParams,
    );

    return _merge(mergeParam);
  }

  /// Merges multiple images, honoring [MergeParam.format] and
  /// [MergeParam.quality].
  ///
  /// Prefers the native merger (supports PNG and JPEG) and falls back to a
  /// Flutter canvas render (PNG only) when the platform implementation is
  /// unavailable, e.g. on desktop/web where no native merger exists.
  Future<Uint8List?> _merge(MergeParam mergeParam) async {
    if (mergeParam.size.width <= 0 || mergeParam.size.height <= 0) {
      debugPrint(
        'Error: mergeParam size invalid in _merge: ${mergeParam.size}',
      );
      return null;
    }

    try {
      final Uint8List? native = await ImageMerger.merge(mergeParam);
      if (native != null) return native;
    } catch (e) {
      debugPrint('Native merge failed, falling back to canvas: $e');
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    if (mergeParam.color != null) {
      canvas.drawColor(mergeParam.color!, BlendMode.srcOver);
    }

    final paint = Paint()..isAntiAlias = false;

    for (final imgParam in mergeParam.imageParams) {
      final img = await decodeImageFromList(imgParam.image);
      try {
        canvas.drawImage(img, imgParam.offset, paint);
      } finally {
        img.dispose();
      }
    }

    final picture = recorder.endRecording();
    try {
      final renderedImage = await picture.toImage(
        mergeParam.size.width.ceil(),
        mergeParam.size.height.ceil(),
      );
      try {
        // NOTE: Flutter canvas can only encode PNG here; JPEG requests are
        // served by the native merger above.
        final byteData = await renderedImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        return byteData?.buffer.asUint8List();
      } finally {
        renderedImage.dispose();
      }
    } finally {
      picture.dispose();
    }
  }

  /// Checks if the scrollable content can still be scrolled.
  bool _canScroll(ScrollController? controller) {
    if (controller == null || !controller.hasClients) return false;
    final position = controller.position;
    if (!position.hasContentDimensions || !position.hasPixels) return false;
    final tolerance = position.physics.toleranceFor(position).distance;
    return !nearEqual(position.maxScrollExtent, position.pixels, tolerance);
  }

  /// Captures a screenshot of the current render boundary.
  Future<Uint8List> _screenshot(double pixelRatio) async {
    if (size.width <= 0 || size.height <= 0) {
      throw Exception('RenderRepaintBoundary size is invalid: $size');
    }
    final img = await toImage(pixelRatio: pixelRatio);
    try {
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert image to byte data');
      }
      return byteData.buffer.asUint8List();
    } finally {
      img.dispose();
    }
  }
}

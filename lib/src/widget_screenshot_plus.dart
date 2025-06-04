import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

import 'image_merger.dart';
import 'merge_param.dart';

/// Supported image formats for screenshot output.
enum ShotFormat { png, jpeg }

/// A widget that enables screenshot functionality of its child.
///
/// Wraps its child in a RenderRepaintBoundary to capture its visual appearance.
class WidgetShotPlus extends SingleChildRenderObjectWidget {
  const WidgetShotPlus({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      WidgetShotPlusRenderRepaintBoundary(context);
}

/// The render object that handles the actual screenshot capture functionality.
class WidgetShotPlusRenderRepaintBoundary extends RenderRepaintBoundary {
  final BuildContext context;

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
    pixelRatio ??= View.of(context).devicePixelRatio;
    quality = quality.clamp(0, 100);

    if (size.width <= 0 || size.height <= 0) {
      debugPrint('Error: RenderRepaintBoundary size is invalid: $size');
      return null;
    }

    double sHeight =
        scrollController?.position.viewportDimension ?? size.height;
    if (sHeight <= 0) sHeight = size.height;

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

    final canScroll = scrollController?.position.maxScrollExtent != 0;

    if (canScroll) {
      scrollController?.jumpTo(0);
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // First visible image
    final Uint8List firstImage = await _screenshot(pixelRatio);
    imageParams.add(
      ImageParam(
        image: firstImage,
        offset: Offset(0, imageHeight),
        size: Size(size.width * pixelRatio, size.height * pixelRatio),
      ),
    );
    imageHeight += sHeight * pixelRatio;

    if (canScroll) {
      int i = 1;
      while (imageHeight < maxHeight * pixelRatio &&
          _canScroll(scrollController)) {
        final nextScroll = sHeight * i;
        final scrollExtent = scrollController!.position.maxScrollExtent;

        if (scrollController.offset + sHeight / 10 > nextScroll) {
          scrollController.jumpTo(nextScroll);
          await Future.delayed(const Duration(milliseconds: 16));
          final img = await _screenshot(pixelRatio);
          imageParams.add(
            ImageParam(
              image: img,
              offset: Offset(0, imageHeight),
              size: Size(size.width * pixelRatio, size.height * pixelRatio),
            ),
          );
          imageHeight += sHeight * pixelRatio;
          i++;
        } else if (nextScroll > scrollExtent) {
          final remainingHeight = scrollExtent + sHeight - sHeight * i;
          scrollController.jumpTo(scrollExtent);
          await Future.delayed(const Duration(milliseconds: 16));
          final img = await _screenshot(pixelRatio);
          imageParams.add(
            ImageParam(
              image: img,
              offset: Offset(
                0,
                imageHeight - ((size.height - remainingHeight) * pixelRatio),
              ),
              size: Size(size.width * pixelRatio, size.height * pixelRatio),
            ),
          );
          imageHeight += remainingHeight * pixelRatio;
          break;
        } else {
          scrollController.jumpTo(scrollController.offset + sHeight / 10);
          await Future.delayed(const Duration(milliseconds: 16));
        }
      }
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
      size: Size(size.width * pixelRatio, imageHeight),
      format: format,
      quality: quality,
      imageParams: imageParams,
    );

    return await _merge(canScroll, mergeParam);
  }

  /// Merges multiple images either using platform-specific implementation or Flutter's canvas.
  Future<Uint8List?> _merge(bool canScroll, MergeParam mergeParam) async {
    if (canScroll) return ImageMerger.merge(mergeParam);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    if (mergeParam.color != null) {
      canvas.drawColor(mergeParam.color!, BlendMode.color);
      canvas.save();
    }

    final paint = Paint()..isAntiAlias = false;

    for (final imgParam in mergeParam.imageParams) {
      final img = await decodeImageFromList(imgParam.image);
      canvas.drawImage(img, imgParam.offset, paint);
    }

    final picture = recorder.endRecording();
    if (mergeParam.size.width <= 0 || mergeParam.size.height <= 0) {
      debugPrint(
        'Error: mergeParam size invalid in _merge: ${mergeParam.size}',
      );
      return null;
    }

    final renderedImage = await picture.toImage(
      mergeParam.size.width.ceil(),
      mergeParam.size.height.ceil(),
    );

    final byteData = await renderedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData?.buffer.asUint8List();
  }

  /// Checks if the scrollable content can still be scrolled.
  bool _canScroll(ScrollController? controller) {
    if (controller == null) return false;
    final position = controller.position;
    final tolerance = position.physics.toleranceFor(position).distance;
    return !nearEqual(position.maxScrollExtent, position.pixels, tolerance);
  }

  /// Captures a screenshot of the current render boundary.
  Future<Uint8List> _screenshot(double pixelRatio) async {
    if (size.width <= 0 || size.height <= 0) {
      throw Exception('RenderRepaintBoundary size is invalid: $size');
    }
    final img = await toImage(pixelRatio: pixelRatio);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to convert image to byte data');
    }
    return byteData.buffer.asUint8List();
  }
}

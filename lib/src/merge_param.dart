import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:widget_screenshot_plus/src/widget_screenshot_plus.dart';

/// Contains parameters required for merging multiple images into one.
///
/// This class holds configuration like background color, output size,
/// image format, quality, and a list of images to merge.
class MergeParam {
  /// Background color of the merged image (optional).
  final Color? color;

  /// Size of the final merged image.
  final Size size;

  /// Output format of the merged image (PNG or JPEG).
  final ShotFormat format;

  /// Quality of the output image (0-100), relevant for JPEG format.
  final int quality;

  /// List of images and their positioning parameters to be merged.
  final List<ImageParam> imageParams;

  /// Creates a new MergeParam instance.
  MergeParam({
    this.color,
    required this.size,
    required this.format,
    required this.quality,
    required this.imageParams,
  });

  /// Converts the MergeParam to a JSON map for platform channel communication.
  Map<String, dynamic> toJson() => {
        if (color != null)
          "color": [
            color!.alpha.toDouble(),
            color!.red.toDouble(),
            color!.green.toDouble(),
            color!.blue.toDouble(),
          ],
        "width": size.width,
        "height": size.height,
        "format": format == ShotFormat.png ? 0 : 1,
        "quality": quality,
        "imageParams": imageParams.map((e) => e.toJson()).toList(),
      };
}

/// Contains parameters for a single image to be merged.
///
/// This includes the image data, its position in the final composition,
/// and its display size.
class ImageParam {
  /// Raw image data in bytes.
  final Uint8List image;

  /// Position of the image in the final composition.
  final Offset offset;

  /// Display size of the image.
  final Size size;

  /// Creates a new ImageParam with specified position and size.
  ImageParam({required this.image, required this.offset, required this.size});

  /// Creates an ImageParam for an image that should be placed at the start
  /// (top) of the composition.
  ImageParam.start(Uint8List image, Size size)
      : this(image: image, offset: const Offset(-1, -1), size: size);

  /// Creates an ImageParam for an image that should be placed at the end
  /// (bottom) of the composition.
  ImageParam.end(Uint8List image, Size size)
      : this(image: image, offset: const Offset(-2, -2), size: size);

  /// Converts the ImageParam to a JSON map for platform channel communication.
  Map<String, dynamic> toJson() => {
        "image": image,
        "dx": offset.dx,
        "dy": offset.dy,
        "width": size.width,
        "height": size.height,
      };
}

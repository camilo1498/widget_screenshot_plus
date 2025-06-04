import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:widget_screenshot_plus/src/widget_screenshot_plus.dart';

class MergeParam {
  final Color? color;
  final Size size;
  final ShotFormat format;
  final int quality;
  final List<ImageParam> imageParams;

  MergeParam({
    this.color,
    required this.size,
    required this.format,
    required this.quality,
    required this.imageParams,
  });

  Map<String, dynamic> toJson() => {
    if (color != null)
      "color": [
        (color!.a * 255.0).round(),
        (color!.r * 255.0).round(),
        (color!.g * 255.0).round(),
        (color!.b * 255.0).round(),
      ],

    "width": size.width,
    "height": size.height,
    "format": format == ShotFormat.png ? 0 : 1,
    "quality": quality,
    "imageParams": imageParams.map((e) => e.toJson()).toList(),
  };
}

class ImageParam {
  final Uint8List image;
  final Offset offset;
  final Size size;

  ImageParam({required this.image, required this.offset, required this.size});

  ImageParam.start(Uint8List image, Size size)
    : this(image: image, offset: const Offset(-1, -1), size: size);

  ImageParam.end(Uint8List image, Size size)
    : this(image: image, offset: const Offset(-2, -2), size: size);

  Map<String, dynamic> toJson() => {
    "image": image,
    "dx": offset.dx,
    "dy": offset.dy,
    "width": size.width,
    "height": size.height,
  };
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_screenshot_plus/widget_screenshot_plus.dart';

void main() {
  test('MergeParam.toJson sends ARGB ints and format codes', () {
    final param = MergeParam(
      color: const Color.fromARGB(255, 10, 20, 30),
      size: const Size(100, 200),
      format: ShotFormat.png,
      quality: 80,
      imageParams: [
        ImageParam(
          image: Uint8List.fromList([1, 2, 3]),
          offset: const Offset(0, 5),
          size: const Size(100, 50),
        ),
      ],
    );

    final json = param.toJson();
    expect(json['color'], [255, 10, 20, 30]);
    expect(json['width'], 100);
    expect(json['height'], 200);
    expect(json['format'], 0);
    expect(json['quality'], 80);
    final images = json['imageParams'] as List;
    expect(images, hasLength(1));
    expect(images.first['dx'], 0);
    expect(images.first['dy'], 5);
  });

  test('MergeParam.toJson uses JPEG format code', () {
    final param = MergeParam(
      size: const Size(10, 10),
      format: ShotFormat.jpeg,
      quality: 70,
      imageParams: const [],
    );

    final json = param.toJson();
    expect(json['format'], 1);
    expect(json.containsKey('color'), isFalse);
  });

  test('ImageParam.start/end use sentinel offsets', () {
    final bytes = Uint8List.fromList([0]);
    expect(ImageParam.start(bytes, const Size(1, 2)).offset,
        const Offset(-1, -1));
    expect(ImageParam.end(bytes, const Size(1, 2)).offset,
        const Offset(-2, -2));
  });
}

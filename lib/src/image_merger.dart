import 'dart:typed_data';

import 'package:widget_screenshot_plus/src/widget_screenshot_plus_platform_interface.dart';

import 'merge_param.dart';

class ImageMerger {
  static Future<Uint8List?> merge(MergeParam mergeParam) {
    return WidgetShotPlusPlatform.instance.mergeToMemory(mergeParam);
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:widget_screenshot_plus/src/widget_screenshot_plus_platform_interface.dart';

import 'merge_param.dart';

class MethodChannelWidgetShotPlus extends WidgetShotPlusPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('widget_shot');

  @override
  Future<Uint8List?> mergeToMemory(MergeParam mergeParam) {
    return methodChannel.invokeMethod<Uint8List>("merge", mergeParam.toJson());
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:widget_screenshot_plus/src/widget_screenshot_plus_platform_interface.dart';

import 'merge_param.dart';

/// An implementation of [WidgetShotPlusPlatform] that uses method channels.
class MethodChannelWidgetShotPlus extends WidgetShotPlusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('widget_shot');

  @override
  Future<Uint8List?> mergeToMemory(MergeParam mergeParam) async {
    final image = await methodChannel.invokeMethod<Uint8List>(
      "merge",
      mergeParam.toJson(),
    );
    return image;
  }
}

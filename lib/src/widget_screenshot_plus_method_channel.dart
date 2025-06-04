import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:widget_screenshot_plus/src/widget_screenshot_plus_platform_interface.dart';

import 'merge_param.dart';

/// Method channel implementation of [WidgetShotPlusPlatform].
///
/// Uses platform channels to communicate with native code for image merging.
class MethodChannelWidgetShotPlus extends WidgetShotPlusPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('widget_shot');

  @override
  Future<Uint8List?> mergeToMemory(MergeParam mergeParam) async {
    try {
      final params = mergeParam.toJson();
      debugPrint(
          'PARAMS SENT TO NATIVE: ${params.toString()}'); // Add this line

      final result =
          await methodChannel.invokeMethod<Uint8List>("merge", params);
      return result;
    } on PlatformException catch (e) {
      debugPrint('PlatformException: ${e.code} - ${e.message}');
      rethrow;
    }
  }
}

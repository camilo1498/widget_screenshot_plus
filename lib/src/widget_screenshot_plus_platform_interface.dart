import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:widget_screenshot_plus/src/widget_screenshot_plus_method_channel.dart';

import 'merge_param.dart';

abstract class WidgetShotPlusPlatform extends PlatformInterface {
  /// Constructs a WidgetShotPlatform.
  WidgetShotPlusPlatform() : super(token: _token);

  static final Object _token = Object();

  static WidgetShotPlusPlatform _instance = MethodChannelWidgetShotPlus();

  /// The default instance of [WidgetShotPlusPlatform] to use.
  ///
  /// Defaults to [MethodChannelWidgetShotPlus].
  static WidgetShotPlusPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WidgetShotPlusPlatform] when
  /// they register themselves.
  static set instance(WidgetShotPlusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Uint8List?> mergeToMemory(MergeParam mergeParam) {
    throw UnimplementedError('mergeToMemory() has not been implemented.');
  }
}

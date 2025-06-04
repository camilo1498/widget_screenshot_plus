import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:widget_screenshot_plus/src/widget_screenshot_plus_method_channel.dart';

import 'merge_param.dart';

/// Platform interface for widget screenshot functionality.
///
/// Defines the contract that platform-specific implementations must adhere to.
abstract class WidgetShotPlusPlatform extends PlatformInterface {
  WidgetShotPlusPlatform() : super(token: _token);

  static final Object _token = Object();
  static WidgetShotPlusPlatform _instance = MethodChannelWidgetShotPlus();

  /// The current instance of [WidgetShotPlusPlatform].
  static WidgetShotPlusPlatform get instance => _instance;

  /// Sets the platform instance.
  static set instance(WidgetShotPlusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Merges multiple images into a single image in memory.
  ///
  /// [mergeParam] Contains all parameters needed for the merge operation.
  /// Returns the merged image as bytes or null if the operation fails.
  Future<Uint8List?> mergeToMemory(MergeParam mergeParam);
}

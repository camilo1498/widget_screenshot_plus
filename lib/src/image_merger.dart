import 'dart:typed_data';

import 'package:widget_screenshot_plus/src/widget_screenshot_plus_platform_interface.dart';

import 'merge_param.dart';

/// A utility class for merging multiple images into a single image.
///
/// This class provides a static method to merge images using the platform-specific
/// implementation of the widget screenshot functionality.
class ImageMerger {
  /// Merges multiple images into a single image based on the provided parameters.
  ///
  /// [mergeParam] Contains all the necessary parameters for the merge operation,
  /// including image list, size, format, and background color.
  ///
  /// Returns a [Future<Uint8List?>] containing the merged image data in bytes,
  /// or null if the merge operation fails.
  static Future<Uint8List?> merge(MergeParam mergeParam) {
    return WidgetShotPlusPlatform.instance.mergeToMemory(mergeParam);
  }
}

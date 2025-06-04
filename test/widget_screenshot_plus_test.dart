import 'package:flutter_test/flutter_test.dart';
import 'package:widget_screenshot_plus/src/widget_screenshot_plus.dart';
import 'package:widget_screenshot_plus/src/widget_screenshot_plus_platform_interface.dart';
import 'package:widget_screenshot_plus/widget_screenshot_plus_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWidgetScreenshotPlusPlatform
    with MockPlatformInterfaceMixin
    implements WidgetScreenshotPlusPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WidgetScreenshotPlusPlatform initialPlatform =
      WidgetScreenshotPlusPlatform.instance;

  test('$MethodChannelWidgetScreenshotPlus is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWidgetScreenshotPlus>());
  });

  test('getPlatformVersion', () async {
    WidgetScreenshotPlus widgetScreenshotPlusPlugin = WidgetScreenshotPlus();
    MockWidgetScreenshotPlusPlatform fakePlatform =
        MockWidgetScreenshotPlusPlatform();
    WidgetScreenshotPlusPlatform.instance = fakePlatform;

    expect(await widgetScreenshotPlusPlugin.getPlatformVersion(), '42');
  });
}

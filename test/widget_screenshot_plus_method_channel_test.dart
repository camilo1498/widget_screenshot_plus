import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_screenshot_plus/widget_screenshot_plus_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelWidgetScreenshotPlus platform = MethodChannelWidgetScreenshotPlus();
  const MethodChannel channel = MethodChannel('widget_screenshot_plus');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}

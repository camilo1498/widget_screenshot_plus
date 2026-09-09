import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:widget_screenshot_plus/widget_screenshot_plus.dart';

/// Smoke tests that exercise the real plugin pipeline on device, including
/// the native merger over the method channel (PNG + JPEG) and the scroll
/// stitching flow.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<ui.Image> decode(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  testWidgets('single widget screenshot as PNG', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WidgetShotPlus(
            key: key,
            child: Container(
              width: 200,
              height: 120,
              color: Colors.blue,
              alignment: Alignment.center,
              child: const Text('Capture me!'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boundary = key.currentContext!.findRenderObject()
        as WidgetShotPlusRenderRepaintBoundary;
    final bytes = await boundary.screenshot(backgroundColor: Colors.white);

    expect(bytes, isNotNull);
    expect(bytes!, isNotEmpty);
    // PNG magic bytes.
    expect(bytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    final image = await decode(bytes);
    expect(image.width, greaterThan(0));
    expect(image.height, greaterThan(0));
    image.dispose();
  });

  testWidgets('single widget screenshot as JPEG (native merger)',
      (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WidgetShotPlus(
            key: key,
            child: Container(
              width: 160,
              height: 100,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boundary = key.currentContext!.findRenderObject()
        as WidgetShotPlusRenderRepaintBoundary;
    final bytes = await boundary.screenshot(
      format: ShotFormat.jpeg,
      quality: 80,
    );

    expect(bytes, isNotNull);
    expect(bytes!, isNotEmpty);
    // JPEG magic bytes.
    expect(bytes.sublist(0, 2), [0xFF, 0xD8]);
    final image = await decode(bytes);
    expect(image.width, greaterThan(0));
    expect(image.height, greaterThan(0));
    image.dispose();
  });

  testWidgets('scrollable content screenshot stitches taller image',
      (tester) async {
    final key = GlobalKey();
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WidgetShotPlus(
            key: key,
            child: SizedBox(
              height: 400,
              child: CustomScrollView(
                controller: controller,
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => SizedBox(
                        height: 200,
                        child: Center(child: Text('Row $i')),
                      ),
                      childCount: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boundary = key.currentContext!.findRenderObject()
        as WidgetShotPlusRenderRepaintBoundary;
    final bytes = await boundary.screenshot(
      scrollController: controller,
      backgroundColor: Colors.white,
    );

    expect(bytes, isNotNull);
    expect(bytes!, isNotEmpty);
    final image = await decode(bytes);
    // 10 rows x 200px = 2000 content px; stitched image must be taller
    // than the 400px viewport (times pixel ratio).
    expect(image.height, greaterThan(400));
    image.dispose();
  });
}

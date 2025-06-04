import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widget_screenshot_plus/widget_screenshot_plus.dart';

/// Demonstrates capturing a screenshot of a single widget with dynamic content.
///
/// Shows how to:
/// 1. Capture a widget wrapped in WidgetShotPlus
/// 2. Handle visibility changes in the screenshot
/// 3. Save and share the captured image
class ExampleSinglePage extends StatefulWidget {
  const ExampleSinglePage({super.key});

  @override
  State<ExampleSinglePage> createState() => _ExampleSinglePageState();
}

class _ExampleSinglePageState extends State<ExampleSinglePage> {
  // Key to identify the WidgetShotPlus boundary
  final GlobalKey _screenshotKey = GlobalKey();
  bool _visible = false;

  /// Captures the widget screenshot and shares it
  Future<void> _takeScreenshot() async {
    try {
      // Find the render boundary
      final boundary =
          _screenshotKey.currentContext?.findRenderObject()
              as WidgetShotPlusRenderRepaintBoundary?;

      // Capture screenshot with specified parameters
      final resultImage = await boundary?.screenshot(
        quality: 100, // Maximum quality
        pixelRatio: 1, // Standard pixel density
        format: ShotFormat.png, // PNG format
        backgroundColor: Colors.white, // White background
      );

      if (resultImage != null) {
        // Save to temporary file
        final dir = await getApplicationDocumentsDirectory();
        final imagePath = await File(
          '${dir.path}/${DateTime.now()}.png',
        ).create();
        await imagePath.writeAsBytes(resultImage);

        // Share the image
        await SharePlus.instance.share(
          ShareParams(files: [XFile(imagePath.path)]),
        );
      }
    } catch (e) {
      debugPrint("Screenshot error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Single Widget Screenshot"),
        actions: [
          TextButton(
            onPressed: _takeScreenshot,
            child: const Text("Shot", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: WidgetShotPlus(
        key: _screenshotKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dynamic header that can be toggled
            Visibility(
              visible: _visible,
              child: const SizedBox(
                height: 160,
                child: Center(
                  child: Text("I am Header", style: TextStyle(fontSize: 32)),
                ),
              ),
            ),
            // Toggle button
            SizedBox(
              height: 160,
              child: Center(
                child: TextButton(
                  onPressed: () => setState(() => _visible = !_visible),
                  child: const Text("Click", style: TextStyle(fontSize: 32)),
                ),
              ),
            ),
            // Dynamic footer that can be toggled
            Visibility(
              visible: _visible,
              child: const SizedBox(
                height: 160,
                child: Center(
                  child: Text("I am Footer", style: TextStyle(fontSize: 32)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

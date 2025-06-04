import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:widget_screenshot_plus/widget_screenshot_plus.dart';

class ExampleSinglePage extends StatefulWidget {
  const ExampleSinglePage({Key? key}) : super(key: key);

  @override
  State<ExampleSinglePage> createState() => _ExampleSinglePageState();
}

class _ExampleSinglePageState extends State<ExampleSinglePage> {
  final GlobalKey _screenshotKey = GlobalKey();
  bool _visible = false;

  Future<void> _takeScreenshot() async {
    try {
      final boundary =
          _screenshotKey.currentContext?.findRenderObject()
              as WidgetShotPlusRenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint("Render boundary not found.");
        return;
      }

      final image = await boundary.screenshot(
        format: ShotFormat.png,
        pixelRatio: 1,
        // backgroundColor: Colors.amberAccent,
      );

      if (image == null) {
        debugPrint("Failed to capture image.");
        return;
      }

      final path =
          '${(await getTemporaryDirectory()).path}/${DateTime.now()}.png';
      final file = File(path);
      await file.writeAsBytes(image);

      debugPrint("Image saved to: $path");
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
            Visibility(
              visible: _visible,
              child: const SizedBox(
                height: 160,
                child: Center(
                  child: Text("I am Header", style: TextStyle(fontSize: 32)),
                ),
              ),
            ),
            SizedBox(
              height: 160,
              child: Center(
                child: TextButton(
                  onPressed: () => setState(() => _visible = !_visible),
                  child: const Text("Click", style: TextStyle(fontSize: 32)),
                ),
              ),
            ),
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

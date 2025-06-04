import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:widget_screenshot_plus/widget_screenshot_plus.dart';

class ExampleListPage extends StatefulWidget {
  const ExampleListPage({Key? key}) : super(key: key);

  @override
  State<ExampleListPage> createState() => _ExampleListPageState();
}

class _ExampleListPageState extends State<ExampleListPage> {
  final GlobalKey _screenshotKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  Future<void> _takeScreenshot() async {
    try {
      final boundary =
          _screenshotKey.currentContext?.findRenderObject()
              as WidgetShotPlusRenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint("Render boundary not found.");
        return;
      }

      final resultImage = await boundary.screenshot(
        scrollController: _scrollController,
        backgroundColor: Colors.white,
        format: ShotFormat.png,
        pixelRatio: 1,
      );

      if (resultImage == null) {
        debugPrint("Failed to capture image.");
        return;
      }

      // Save to gallery
      final galleryResult = await ImageGallerySaverPlus.saveImage(resultImage);
      debugPrint("Gallery save result: $galleryResult");

      // Save to temp file
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${DateTime.now()}.png';
      final file = File(filePath)..writeAsBytesSync(resultImage);
      debugPrint("Image saved to: $filePath");
    } catch (error) {
      debugPrint("Screenshot error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screenshot Example"),
        actions: [
          TextButton(
            onPressed: _takeScreenshot,
            child: const Text("Shot", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: WidgetShotPlus(
        key: _screenshotKey,
        child: ListView.separated(
          controller: _scrollController,
          itemCount: 100,
          itemBuilder: (context, index) {
            return Container(
              height: 160,
              alignment: Alignment.center,
              child: Text(
                "Example item $index",
                style: const TextStyle(fontSize: 32),
              ),
            );
          },
          separatorBuilder: (context, index) =>
              const Divider(height: 1, color: Colors.grey),
        ),
      ),
    );
  }
}

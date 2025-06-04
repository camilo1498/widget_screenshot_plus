import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:widget_screenshot_plus/widget_screenshot_plus.dart';

class ExampleScrollViewExtraPage extends StatefulWidget {
  const ExampleScrollViewExtraPage({Key? key}) : super(key: key);

  @override
  State<ExampleScrollViewExtraPage> createState() =>
      _ExampleScrollViewExtraPageState();
}

class _ExampleScrollViewExtraPageState
    extends State<ExampleScrollViewExtraPage> {
  final _headerKey = GlobalKey();
  final _bodyKey = GlobalKey();
  final _footerKey = GlobalKey();
  final _scrollController = ScrollController();

  Future<Uint8List?> _captureSection(GlobalKey key) async {
    final boundary =
        key.currentContext?.findRenderObject()
            as WidgetShotPlusRenderRepaintBoundary?;
    return await boundary?.screenshot(format: ShotFormat.png, pixelRatio: 1);
  }

  Future<void> _takeScreenshot() async {
    try {
      final headerImage = await _captureSection(_headerKey);
      final footerImage = await _captureSection(_footerKey);

      final bodyBoundary =
          _bodyKey.currentContext?.findRenderObject()
              as WidgetShotPlusRenderRepaintBoundary?;

      if (bodyBoundary == null) {
        debugPrint("Body render boundary not found.");
        return;
      }

      final resultImage = await bodyBoundary.screenshot(
        scrollController: _scrollController,
        extraImage: [
          if (headerImage != null)
            ImageParam.start(headerImage, _headerKey.currentContext!.size!),
          if (footerImage != null)
            ImageParam.end(footerImage, _footerKey.currentContext!.size!),
        ],
        backgroundColor: Colors.white,
        format: ShotFormat.png,
        pixelRatio: 1,
      );

      if (resultImage == null) {
        debugPrint("Failed to capture screenshot.");
        return;
      }

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/${DateTime.now()}.png';
      final file = File(filePath);
      await file.writeAsBytes(resultImage);

      debugPrint("Screenshot saved to: $filePath");
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
      body: Column(
        children: [
          WidgetShotPlus(
            key: _headerKey,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Header Line 1"),
                  Text("Header Line 2"),
                  Text("Header Line 3"),
                  Text("Header Line 4"),
                ],
              ),
            ),
          ),
          Expanded(
            child: WidgetShotPlus(
              key: _bodyKey,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: List.generate(100, (i) {
                    return SizedBox(
                      height: 160,
                      child: Center(
                        child: Text(
                          "Sample content line $i",
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          WidgetShotPlus(
            key: _footerKey,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Footer Line 1"),
                  Text("Footer Line 2"),
                  Text("Footer Line 3"),
                  Text("Footer Line 4"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

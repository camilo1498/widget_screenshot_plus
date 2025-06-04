import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widget_screenshot_plus/widget_screenshot_plus.dart';

/// Demonstrates capturing a screenshot of a scrollable list with headers/footers.
///
/// Shows how to:
/// 1. Capture long scrollable content
/// 2. Handle Sliver widgets in screenshots
/// 3. Use a scroll controller for multi-part capture
class ExampleListExtraPage extends StatefulWidget {
  const ExampleListExtraPage({super.key});

  @override
  State<ExampleListExtraPage> createState() => _ExampleListExtraPageState();
}

class _ExampleListExtraPageState extends State<ExampleListExtraPage> {
  final _shotKey = GlobalKey();
  final _scrollController = ScrollController();

  /// Captures the entire scrollable content as a single image
  Future<void> _takeScreenshot() async {
    try {
      // Find the render boundary
      final boundary = _shotKey.currentContext?.findRenderObject()
          as WidgetShotPlusRenderRepaintBoundary?;

      // Capture screenshot with scroll handling
      final resultImage = await boundary?.screenshot(
        quality: 100,
        format: ShotFormat.png,
        backgroundColor: Colors.white,
        scrollController: _scrollController, // Handle scrolling content
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
    } catch (e, s) {
      debugPrint("Error capturing screenshot: $e\n$s");
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
        key: _shotKey,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header section 1
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Header Section 1"),
                    SizedBox(height: 4),
                    Text("Another header line"),
                  ],
                ),
              ),
            ),
            // Header section 2
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                color: Colors.blue,
                child: const Text(
                  "Header Section 2",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            // Main scrollable content
            SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FlutterLogo(size: 100),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Text(
                          "The Container widget lets you create a rectangular visual element. "
                          "A container can be decorated with a BoxDecoration, such as a background, a border, or a shadow. "
                          "It can also have margins, padding, and constraints applied to its size.",
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FlutterLogo(size: 100),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Text(
                          "The Container widget lets you create a rectangular visual element. "
                          "A container can be decorated with a BoxDecoration, such as a background, a border, or a shadow. "
                          "It can also have margins, padding, and constraints applied to its size.",
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FlutterLogo(size: 100),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Text(
                          "The Container widget lets you create a rectangular visual element. "
                          "A container can be decorated with a BoxDecoration, such as a background, a border, or a shadow. "
                          "It can also have margins, padding, and constraints applied to its size.",
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FlutterLogo(size: 100),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Text(
                          "The Container widget lets you create a rectangular visual element. "
                          "A container can be decorated with a BoxDecoration, such as a background, a border, or a shadow. "
                          "It can also have margins, padding, and constraints applied to its size.",
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FlutterLogo(size: 100),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Text(
                          "The Container widget lets you create a rectangular visual element. "
                          "A container can be decorated with a BoxDecoration, such as a background, a border, or a shadow. "
                          "It can also have margins, padding, and constraints applied to its size.",
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
            // Footer section
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Footer Section 1"),
                    SizedBox(height: 4),
                    Text("Another footer line"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

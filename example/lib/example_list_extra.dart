import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widget_screenshot_plus/widget_screenshot_plus.dart';

class ExampleListExtraPage extends StatefulWidget {
  const ExampleListExtraPage({Key? key}) : super(key: key);

  @override
  State<ExampleListExtraPage> createState() => _ExampleListExtraPageState();
}

class _ExampleListExtraPageState extends State<ExampleListExtraPage> {
  final _headerKey1 = GlobalKey();
  final _headerKey2 = GlobalKey();
  final _bodyKey = GlobalKey();
  final _footerKey = GlobalKey();
  final _scrollController = ScrollController();

  Future<Uint8List?> _captureSection(GlobalKey key) async {
    final boundary =
        key.currentContext?.findRenderObject()
            as WidgetShotPlusRenderRepaintBoundary?;
    if (boundary == null || boundary.size.isEmpty) {
      debugPrint('Boundary missing or empty for key: $key');
      return null;
    }
    return boundary.screenshot(format: ShotFormat.png, quality: 100);
  }

  Future<void> _takeScreenshot() async {
    try {
      final dpr = MediaQuery.of(context).devicePixelRatio;

      final headerImage1 = await _captureSection(_headerKey1);
      final headerImage2 = await _captureSection(_headerKey2);
      final footerImage = await _captureSection(_footerKey);

      final bodyBoundary =
          _bodyKey.currentContext?.findRenderObject()
              as WidgetShotPlusRenderRepaintBoundary?;
      if (bodyBoundary == null || bodyBoundary.size.isEmpty) {
        debugPrint("Body boundary missing or empty.");
        return;
      }

      ImageParam? _makeImageParam(Uint8List? img, GlobalKey key, bool isStart) {
        if (img == null) return null;
        final size = key.currentContext?.size;
        if (size == null) return null;
        return isStart
            ? ImageParam.start(img, size * dpr)
            : ImageParam.end(img, size * dpr);
      }

      final extraImages = [
        _makeImageParam(headerImage1, _headerKey1, true),
        _makeImageParam(headerImage2, _headerKey2, true),
        _makeImageParam(footerImage, _footerKey, false),
      ].whereType<ImageParam>().toList();

      final resultImage = await bodyBoundary.screenshot(
        scrollController: _scrollController,
        extraImage: extraImages,
        backgroundColor: Colors.white,
        format: ShotFormat.png,
        quality: 100,
      );

      if (resultImage == null) {
        debugPrint("Screenshot failed.");
        return;
      }

      final file = await File(
        '${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.png',
      ).writeAsBytes(resultImage);

      debugPrint("Saved image to: ${file.path}");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Image saved successfully!\nPath: ${file.path}"),
        ),
      );

      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } catch (e, s) {
      debugPrint("Error capturing screenshot: $e\n$s");
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
          key: _headerKey1,
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
        WidgetShotPlus(
          key: _headerKey2,
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
        Expanded(
          child: WidgetShotPlus(
            key: _bodyKey,
            child: ListView.separated(
              controller: _scrollController,
              itemCount: 5,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Colors.grey),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                child: Row(
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
              ),
            ),
          ),
        ),
        WidgetShotPlus(
          key: _footerKey,
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
  );
}

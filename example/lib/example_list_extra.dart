import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widget_screenshot_plus/widget_screenshot_plus.dart';

class ExampleListExtraPage extends StatefulWidget {
  const ExampleListExtraPage({Key? key}) : super(key: key);

  @override
  State<ExampleListExtraPage> createState() => _ExampleListExtraPageState();
}

class _ExampleListExtraPageState extends State<ExampleListExtraPage>
    with SingleTickerProviderStateMixin {
  GlobalKey _shotHeaderKey = GlobalKey();

  GlobalKey _shotHeaderKey2 = GlobalKey();

  GlobalKey _shotKey = GlobalKey();
  GlobalKey _shotFooterKey = GlobalKey();

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("截图"),
        actions: [
          TextButton(
            onPressed: () async {
              WidgetShotPlusRenderRepaintBoundary headerBoundary =
                  _shotHeaderKey.currentContext!.findRenderObject()
                      as WidgetShotPlusRenderRepaintBoundary;
              var headerImage = await headerBoundary.screenshot(
                format: ShotFormat.png,
                quality: 100,
              );

              WidgetShotPlusRenderRepaintBoundary headerBoundary2 =
                  _shotHeaderKey2.currentContext!.findRenderObject()
                      as WidgetShotPlusRenderRepaintBoundary;
              var headerImage2 = await headerBoundary2.screenshot(
                format: ShotFormat.png,
              );

              WidgetShotPlusRenderRepaintBoundary footerBoundary =
                  _shotFooterKey.currentContext!.findRenderObject()
                      as WidgetShotPlusRenderRepaintBoundary;
              var footerImage = await footerBoundary.screenshot(
                format: ShotFormat.png,
              );

              WidgetShotPlusRenderRepaintBoundary repaintBoundary =
                  _shotKey.currentContext!.findRenderObject()
                      as WidgetShotPlusRenderRepaintBoundary;
              var resultImage = await repaintBoundary.screenshot(
                scrollController: _scrollController,
                extraImage: [
                  if (headerImage != null)
                    ImageParam.start(
                      headerImage,
                      _shotHeaderKey.currentContext!.size! *
                          window.devicePixelRatio,
                    ),
                  if (headerImage2 != null)
                    ImageParam.start(
                      headerImage2,
                      _shotHeaderKey2.currentContext!.size! *
                          window.devicePixelRatio,
                    ),
                  if (footerImage != null)
                    ImageParam.end(
                      footerImage,
                      _shotFooterKey.currentContext!.size! *
                          window.devicePixelRatio,
                    ),
                ],
                format: ShotFormat.png,
                backgroundColor: Colors.black,
              );

              try {
                /// 存储的文件的路径
                String path = (await getTemporaryDirectory()).path;
                path += '/${DateTime.now().toString()}.png';
                File file = File(path);
                if (!file.existsSync()) {
                  file.createSync();
                }
                await file.writeAsBytes(resultImage!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("save success!\npath = ${file.path}")),
                );
                debugPrint("result = ${file.path}");

                final params = ShareParams(
                  text: 'Great picture',
                  files: [XFile(file.path)],
                );

                await SharePlus.instance.share(params);
              } catch (error) {
                debugPrint("error = ${error}");
              }
            },
            child: const Text("Shot", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          WidgetShotPlus(
            key: _shotHeaderKey,
            child: Container(
              color: Colors.white,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("TestHeader"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("TestHeader"),
                  ),
                ],
              ),
            ),
          ),
          WidgetShotPlus(
            key: _shotHeaderKey2,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("TestHeader2", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          Expanded(
            child: WidgetShotPlus(
              key: _shotKey,

              child: ListView.separated(
                controller: _scrollController,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.only(
                      top: 12,
                      right: 12,
                      bottom: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FlutterLogo(size: 100),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              shape: BoxShape.rectangle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(0, 0),
                                  blurRadius: 14,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Text(
                              "The Container widget lets you create a rectangular visual element. A container can be decorated with a BoxDecoration, such as a background, a border, or a shadow. A Container can also have margins, padding, and constraints applied to its size.",
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(height: 1, color: Colors.grey);
                },
                itemCount: 5,
              ),
            ),
          ),
          WidgetShotPlus(
            key: _shotFooterKey,
            child: Container(
              color: Colors.white,
              width: double.infinity,
              child: Builder(
                builder: (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("TestFooter"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("TestFooter"),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

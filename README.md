# Widget Screenshot Plus - Flutter Package

![Pub Version](https://img.shields.io/pub/v/widget_screenshot_plus)
![License](https://img.shields.io/badge/license-MIT-blue)

This package is a Fork of [widget_screenshot](https://pub.dev/packages/widget_screenshot)
updated to the lasted version of flutter and dart.

A Flutter package for capturing widgets as images, 
including scrollable content and complex layouts. Perfect for sharing app content, creating previews, 
or saving widget states.

## Features

- 📸 Capture any widget as an image
- 🖼️ Handle scrollable content (ListView, CustomScrollView, etc.)
- 🎨 Customize output format (PNG/JPEG) and quality
- 🖌️ Add background colors to screenshots
- 📱 Support for high DPI screens with pixel ratio control
- 🧩 Merge multiple images into one composition

## Android
<div style="display: flex; flex-wrap: wrap; gap: 20px;">
  <div>
    <img src="https://github.com/camilo1498/widget_screenshot_plus/blob/master/media_doc/list_scroll_android.gif?raw=true" width="250" alt="list_scroll_android">
    <img src="https://github.com/camilo1498/widget_screenshot_plus/blob/master/media_doc/single_widget_android.gif?raw=true" width="250" alt="single_widget_android">
  </div>
</div>

## IOS
<div style="display: flex; flex-wrap: wrap; gap: 20px;">
  <div>
    <img src="https://github.com/camilo1498/widget_screenshot_plus/blob/master/media_doc/list_scroll_ios.gif?raw=true" width="250" alt="list_scroll_ios">
    <img src="https://github.com/camilo1498/widget_screenshot_plus/blob/master/media_doc/single_widget_ios.gif?raw=true" width="250" alt="single_widget_ios">
  </div>
</div>

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  widget_screenshot_plus: ^latest_version
```

## Basic Usage

### 1. Wrap your widget

```dart
WidgetShotPlus(
  key: _screenshotKey,
  child: YourWidget(),
)
```

### 2. Capture the screenshot

```dart
final boundary = _screenshotKey.currentContext?.findRenderObject()
        as WidgetShotPlusRenderRepaintBoundary?;

final imageBytes = await boundary?.screenshot(
  format: ShotFormat.png,
  quality: 100,
);
```

## Examples

### Simple Widget Capture

```dart
// Wrap your widget
WidgetShotPlus(
  key: _screenshotKey,
  child: Container(
    color: Colors.blue,
    child: Text('Capture me!'),
  ),
)

// Capture it
final imageBytes = await boundary.screenshot();
```

### Scrollable Content

```dart
// Use with scroll controller
final _scrollController = ScrollController();

WidgetShotPlus(
  key: _screenshotKey,
  child: ListView(
    controller: _scrollController,
    children: [...],
  ),
)

// Capture entire scrollable content
final imageBytes = await boundary.screenshot(
  scrollController: _scrollController,
);
```

### Save and Share

```dart
// Save to file
final dir = await getApplicationDocumentsDirectory();
final imageFile = File('${dir.path}/screenshot.png');
await imageFile.writeAsBytes(imageBytes!);

// Share using share_plus
await Share.shareXFiles([XFile(imageFile.path)]);
```

## Advanced Options

| Parameter         | Description                          | Default       |
|-------------------|--------------------------------------|---------------|
| `format`          | Output format (PNG/JPEG)             | `ShotFormat.png` |
| `quality`         | Image quality (0-100)                | `100`         |
| `pixelRatio`      | Device pixel ratio                   | Device default|
| `backgroundColor` | Background color for the screenshot  | `null` (transparent) |
| `scrollController`| For capturing scrollable content     | `null`        |
| `maxHeight`       | Maximum height for scroll capture    | `10000`       |

## FAQ

**Q: Can I capture widgets that are not currently visible on screen?**  
A: Yes! The package can capture the entire widget tree regardless of visibility.

**Q: How does it handle platform differences?**  
A: The package uses a platform interface with method channel implementation, ensuring consistent behavior across iOS and Android.


## Limitations

- Very large captures may cause memory issues (consider splitting extremely long content)
- Web support requires canvas-based rendering
- Some platform-specific widgets may render differently in screenshots

## Contributing

Contributions are welcome! Please open issues or pull requests for any bugs or feature suggestions.

## License

MIT - See [LICENSE](LICENSE) for details.
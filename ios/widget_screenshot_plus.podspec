#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint widget_screenshot_plus.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'widget_screenshot_plus'
  s.version          = '0.0.9'
  s.summary          = 'Capture Flutter widgets as images with scrollable content support.'
  s.description      = <<-DESC
Capture Flutter widgets as images, including scrollable content and complex layouts.
Fork of widget_screenshot, updated for recent Flutter and Dart releases.
                       DESC
  s.homepage         = 'https://github.com/camilo1498/widget_screenshot_plus'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'camilo1498' => 'https://github.com/camilo1498' }
  s.source           = { :path => '.' }
  s.source_files = 'widget_screenshot_plus/Sources/widget_screenshot_plus/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.resource_bundles = {
    'widget_screenshot_plus_privacy' => ['widget_screenshot_plus/Sources/widget_screenshot_plus/PrivacyInfo.xcprivacy']
  }
end

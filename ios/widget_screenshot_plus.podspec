#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint widget_screenshot_plus.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'widget_screenshot_plus'
  s.version          = '0.0.1'
  s.summary          = 'A fork of widget_screenshot plugin, updated for flutter 3.32.0'
  s.description      = <<-DESC
A fork of widget_screenshot plugin, updated for flutter 3.32.0
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'widget_screenshot_plus/Sources/widget_screenshot_plus/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.resource_bundles = {
    'widget_screenshot_plus_privacy' => ['widget_screenshot_plus/Sources/widget_screenshot_plus/PrivacyInfo.xcprivacy']
  }
end

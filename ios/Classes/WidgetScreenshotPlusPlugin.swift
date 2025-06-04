import Flutter
import UIKit

public class WidgetScreenshotPlusPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "widget_shot",
            binaryMessenger: registrar.messenger()
        )
        let instance = WidgetScreenshotPlusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "merge":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(
                    code: "invalid_args",
                    message: "Arguments must be a dictionary",
                    details: nil
                ))
                return
            }

            guard let param = MergeParam(from: args) else {
                result(FlutterError(
                    code: "invalid_args",
                    message: "Invalid or missing parameters",
                    details: args
                ))
                return
            }

            // Process in background thread for large images
            DispatchQueue.global(qos: .userInitiated).async {
                let merger = Merger(param)
                let output = merger.merge()

                DispatchQueue.main.async {
                    if let output = output {
                        result(output)
                    } else {
                        result(FlutterError(
                            code: "merge_failed",
                            message: "Could not generate image",
                            details: nil
                        ))
                    }
                }
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
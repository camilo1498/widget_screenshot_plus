import Flutter
import Foundation
import UIKit

struct MergeParam {
    let color: UIColor?
    let width: CGFloat
    let height: CGFloat
    let format: Int
    let quality: Int
    let imageParams: [ImageParam]

    init?(from dict: [String: Any]) {
        // Handle numbers arriving as Int, Double, or NSNumber from Dart.
        func doubleValue(_ value: Any?) -> Double? {
            (value as? NSNumber)?.doubleValue
        }
        func intValue(_ value: Any?) -> Int? {
            (value as? NSNumber)?.intValue
        }
        guard let width = doubleValue(dict["width"]),
              let height = doubleValue(dict["height"]),
              let format = intValue(dict["format"]),
              let quality = intValue(dict["quality"]),
              let images = dict["imageParams"] as? [[String: Any]] else {
            return nil
        }

        self.width = CGFloat(width)
        self.height = CGFloat(height)
        self.format = format
        self.quality = min(max(quality, 0), 100) // Clamp quality 0-100
        self.imageParams = images.compactMap { ImageParam(from: $0) }

        // Validate image params exist
        if self.imageParams.isEmpty {
            return nil
        }

        // Safer color parsing
        if let rgba = dict["color"] as? [NSNumber], rgba.count == 4 {
            let components = rgba.map { CGFloat($0.floatValue) / 255.0 }
            self.color = UIColor(
                red: components[1],
                green: components[2],
                blue: components[3],
                alpha: components[0]
            )
        } else {
            self.color = nil
        }
    }
}

struct ImageParam {
    let image: Data
    let dx: CGFloat
    let dy: CGFloat
    let width: CGFloat
    let height: CGFloat

    init?(from dict: [String: Any]) {
        func doubleValue(_ value: Any?) -> Double? {
            (value as? NSNumber)?.doubleValue
        }
        guard let typedImage = dict["image"] as? FlutterStandardTypedData,
              let dx = doubleValue(dict["dx"]),
              let dy = doubleValue(dict["dy"]),
              let width = doubleValue(dict["width"]),
              let height = doubleValue(dict["height"]) else {
            return nil
        }

        self.image = typedImage.data
        self.dx = CGFloat(dx)
        self.dy = CGFloat(dy)
        self.width = CGFloat(width)
        self.height = CGFloat(height)

        // Validate image data
        if self.image.isEmpty {
            return nil
        }
    }
}

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
        // Handle both Int and Double from Dart
        guard let width = (dict["width"] as? NSNumber)?.doubleValue,
              let height = (dict["height"] as? NSNumber)?.doubleValue,
              let format = dict["format"] as? Int,
              let quality = dict["quality"] as? Int,
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
        guard let image = dict["image"] as? FlutterStandardTypedData,
              let dx = (dict["dx"] as? NSNumber)?.doubleValue,
              let dy = (dict["dy"] as? NSNumber)?.doubleValue,
              let width = (dict["width"] as? NSNumber)?.doubleValue,
              let height = (dict["height"] as? NSNumber)?.doubleValue else {
            return nil
        }

        self.image = image.data
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
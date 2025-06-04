import Flutter
import Foundation
import UIKit

struct MergeParam {
    var color: UIColor?
    var width: Int
    var height: Int
    var format: Int
    var quality: Int
    var imageParams: [ImageParam]

    init?(from dict: [String: Any]) {
        guard
            let width = dict["width"] as? Int,
            let height = dict["height"] as? Int,
            let format = dict["format"] as? Int,
            let quality = dict["quality"] as? Int,
            let images = dict["imageParams"] as? [[String: Any]]
        else {
            return nil
        }

        self.width = width
        self.height = height
        self.format = format
        self.quality = quality
        self.imageParams = images.compactMap { ImageParam(from: $0) }

        if let rgba = dict["color"] as? [Int], rgba.count == 4 {
            self.color = UIColor(red: CGFloat(rgba[1]) / 255.0,
                                 green: CGFloat(rgba[2]) / 255.0,
                                 blue: CGFloat(rgba[3]) / 255.0,
                                 alpha: CGFloat(rgba[0]) / 255.0)
        }
    }
}

struct ImageParam {
    var image: Data
    var dx: Int
    var dy: Int
    var width: Int
    var height: Int

    init?(from dict: [String: Any]) {
        guard
            let image = dict["image"] as? FlutterStandardTypedData,
            let dx = dict["dx"] as? Int,
            let dy = dict["dy"] as? Int,
            let width = dict["width"] as? Int,
            let height = dict["height"] as? Int
        else {
            return nil
        }

        self.image = image.data
        self.dx = dx
        self.dy = dy
        self.width = width
        self.height = height
    }
}

import Flutter
import Foundation
import UIKit

class Merger {
    private let mergeParam: MergeParam
    private let formatPng = 0

    init(_ param: MergeParam) {
        self.mergeParam = param
    }

    func merge() -> FlutterStandardTypedData? {
        // Validate size
        guard mergeParam.width > 0, mergeParam.height > 0 else {
            return nil
        }

        let size = CGSize(width: mergeParam.width, height: mergeParam.height)

        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        // Draw background if color exists
        if let color = mergeParam.color {
            color.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
        }

        // Draw all images
        for img in mergeParam.imageParams {
            guard let uiImage = UIImage(data: img.image),
                  img.width > 0, img.height > 0 else {
                continue
            }

            let rect = CGRect(x: img.dx, y: img.dy,
                            width: img.width, height: img.height)
            uiImage.draw(in: rect)
        }

        guard let resultImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        let imageData: Data?
        if mergeParam.format == formatPng {
            imageData = resultImage.pngData()
        } else {
            let quality = CGFloat(mergeParam.quality) / 100.0
            imageData = resultImage.jpegData(compressionQuality: quality)
        }

        return imageData.map { FlutterStandardTypedData(bytes: $0) }
    }
}
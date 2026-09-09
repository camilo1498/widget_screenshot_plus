import Flutter
import Foundation
import UIKit

class Merger {
    private let mergeParam: MergeParam
    private let formatPng = 0
    /// Upper bound on canvas pixels to avoid OOM on huge scroll captures.
    private let maxPixels: CGFloat = 16_000 * 16_000

    init(_ param: MergeParam) {
        self.mergeParam = param
    }

    func merge() -> FlutterStandardTypedData? {
        // Validate size
        guard mergeParam.width > 0, mergeParam.height > 0,
              !mergeParam.imageParams.isEmpty,
              mergeParam.width * mergeParam.height <= maxPixels else {
            return nil
        }

        let size = CGSize(width: mergeParam.width, height: mergeParam.height)
        let format = UIGraphicsImageRendererFormat()
        // Sizes from Dart are already multiplied by pixelRatio, so render at
        // scale 1 to get exact pixel dimensions.
        format.scale = 1.0
        format.opaque = mergeParam.color != nil

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let resultImage = renderer.image { _ in
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

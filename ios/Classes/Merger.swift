import Flutter
import Foundation
import UIKit

class Merger {
    private let mergeParam: MergeParam
    private let FormatPng = 0

    init(_ param: MergeParam) {
        self.mergeParam = param
    }

    func merge() -> FlutterStandardTypedData? {
        let size = CGSize(width: mergeParam.width, height: mergeParam.height)

        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        if let color = mergeParam.color {
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(color.cgColor)
            context?.fill(CGRect(origin: .zero, size: size))
        }

        for img in mergeParam.imageParams {
            guard let uiImage = UIImage(data: img.image) else { continue }
            let rect = CGRect(x: img.dx, y: img.dy, width: img.width, height: img.height)
            uiImage.draw(in: rect)
        }

        guard let resultImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()

        let imageData: Data?
        if mergeParam.format == FormatPng {
            imageData = resultImage.pngData()
        } else {
            imageData = resultImage.jpegData(compressionQuality: CGFloat(mergeParam.quality) / 100.0)
        }

        guard let data = imageData else { return nil }
        return FlutterStandardTypedData(bytes: data)
    }
}

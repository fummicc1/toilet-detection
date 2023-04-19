import CoreML
import UIKit
import CoreGraphics


public class ToiletDetection {

    let model: mobilenetv3

    public init() {
        guard let url = Bundle.module.url(
            forResource: "mobilenetv3",
            withExtension: "mlmodelc"
        ) else {
            fatalError()
        }
        model = try! mobilenetv3(
            contentsOf: url
        )
    }

    public func perform(image: UIImage) -> Double {
        guard let buffer = image.pixelBuffer(
            width: 224,
            height: 224,
            pixelFormatType: kCVPixelFormatType_32ARGB,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            alphaInfo: .noneSkipFirst
        ) else {
            fatalError()
        }
        let result = try! model.prediction(input: mobilenetv3Input(img: buffer))
        let ret = result.classLabel_probs["toilet seat"] ?? .zero
        return ret
    }
}

extension ToiletDetection {
    func perform(image: MLShapedArray<Double>) {

    }
}

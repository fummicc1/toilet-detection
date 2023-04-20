//
//  ContentView.swift
//  Example
//
//  Created by Fumiya Tanaka on 2023/04/20.
//

import SwiftUI
import ToiletDetection


struct ContentView: View {

    @State private var prob: Double = 0
    @State private var latestFrame: UIImage?
    private let toiletDetection = ToiletDetection()
    @State private var cameraFrame = CGRect(
        origin: .zero,
        size: .init(
            width: 320,
            height: 320
        )
    )

    var body: some View {
        VStack {
            CameraView(                
                onUpdateFrame: { buffer in
                    let ciImage = CIImage(cvImageBuffer: buffer).oriented(.right)
                    let ciContext = CIContext()
                    let cgImage = ciContext.createCGImage(
                        ciImage,
                        from: ciImage.extent
                    )!
                    let image = UIImage(cgImage: cgImage)
                    Task {
                        await MainActor.run {
                            latestFrame = image
                        }
                    }
                },
                frame: cameraFrame
            )
            .frame(width: cameraFrame.width, height: cameraFrame.height)
            if let latestFrame {
                Image(uiImage: latestFrame)
                    .resizable()
                    .frame(width: 120, height: 120)
            }
            Text("Toilet Seat existence: \(prob)%")
        }
        .padding()
        .task {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if let image = self.latestFrame {
                    Task {
                        self.prob = await validate(image: image)
                    }
                }
            }
        }
    }

    func validate(image: UIImage) async -> Double {
        let prob = await toiletDetection.perform(image: image) * 100
        return prob
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  CameraView.swift
//  Example
//
//  Created by Fumiya Tanaka on 2023/04/20.
//

import Foundation
import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {

    @State private var onUpdateFrame: (CVPixelBuffer) -> Void
    @State private var frame: CGRect

    init(onUpdateFrame: @escaping (CVPixelBuffer) -> Void, frame: CGRect) {
        _onUpdateFrame = State(initialValue: onUpdateFrame)
        _frame = .init(initialValue: frame)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onUpdateFrame: onUpdateFrame)
    }

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: frame)
        view.layer.addSublayer(context.coordinator.videoLayer)
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.frame = frame
        context.coordinator.videoLayer.frame = frame
    }

    class Coordinator: NSObject {
        let session: AVCaptureSession
        var device: AVCaptureDevice?
        let output: AVCaptureVideoDataOutput = .init()
        var videoLayer: AVCaptureVideoPreviewLayer

        private var counter: Int = 0

        let queue = DispatchQueue(label: "dev.fummicc1.toilet-detector", qos: .userInitiated)

        let onUpdateFrame: (CVPixelBuffer) -> Void


        init(onUpdateFrame: @escaping (CVPixelBuffer) -> Void) {
            self.onUpdateFrame = onUpdateFrame
            session = AVCaptureSession()
            if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                self.device = device
            } else if let device = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
                self.device = device
            }
            let audioDevice = AVCaptureDevice.default(
                for: AVMediaType.audio
            )

            // video input setting
            let videoInput = try! AVCaptureDeviceInput(device: device!)
            session.addInput(videoInput)

            // audio input setting
            let audioInput = try! AVCaptureDeviceInput(device: audioDevice!)
            session.addInput(audioInput)

            session.addOutput(output)

            // video quality setting
            session.beginConfiguration()
            if session.canSetSessionPreset(.hd4K3840x2160) {
                session.sessionPreset = .hd4K3840x2160
            } else if session.canSetSessionPreset(.high) {
                session.sessionPreset = .high
            }
            session.commitConfiguration()

            // video preview layer
            videoLayer = AVCaptureVideoPreviewLayer(session: session)
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            super.init()
            output.setSampleBufferDelegate(self, queue: queue)

            queue.async { [weak self] in
                self?.session.startRunning()
            }
        }
    }
}

extension CameraView.Coordinator: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = sampleBuffer.imageBuffer else {
            return
        }
        counter += 1
        if counter % 100 != 0 {
            return
        }
        counter = 0
        onUpdateFrame(imageBuffer)
    }

    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print(sampleBuffer.attachments[.droppedFrameReason])
    }
}

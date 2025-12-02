//
//  SystemCameraService.swift
//  MoodSnap
//
//  Created by Tyler Austin on 11/2/25.
//

import Foundation
import AVFoundation
import CoreVideo

final class SystemCameraService: NSObject, CameraService {
    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "SystemCameraService.CaptureQueue")
    private let bufferBridge = AsyncStreamBridge<CVPixelBuffer>()

    var pixelBufferStream: AsyncStream<CVPixelBuffer> { bufferBridge.stream }
    private(set) var previewLayer: AVCaptureVideoPreviewLayer?

    func start() async throws {
        // Request permission if needed
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            let granted = await withCheckedContinuation { cont in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    cont.resume(returning: granted)
                }
            }
            guard granted else {
                throw NSError(domain: "SystemCameraService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Camera access denied"])
            }
        } else if status != .authorized {
            throw NSError(domain: "SystemCameraService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Camera access denied"])
        }

        if session.inputs.isEmpty {
            try configureSession()
        }

        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = .resizeAspectFill
        }

        if !session.isRunning {
            queue.async { [weak self] in
                guard let self else { return }
                if !self.session.isRunning {
                    self.session.startRunning()
                }
            }
        }
    }

    func stop() {
        queue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
            self.bufferBridge.finish()
        }
    }

    private func configureSession() throws {
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) ??
                AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            session.commitConfiguration()
            throw NSError(domain: "SystemCameraService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No camera available"])
        }

        let input = try AVCaptureDeviceInput(device: device)
        if session.canAddInput(input) { session.addInput(input) }

        let settingsKey = kCVPixelBufferPixelFormatTypeKey as String
        videoOutput.videoSettings = [settingsKey: Int(kCVPixelFormatType_32BGRA)]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        if session.canAddOutput(videoOutput) { session.addOutput(videoOutput) }
        videoOutput.setSampleBufferDelegate(self, queue: queue)

        session.commitConfiguration()
    }
}

extension SystemCameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pb = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        bufferBridge.yield(pb)
    }
}

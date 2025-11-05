//
//  ARFaceCameraService.swift
//  MoodSnap
//
//  Created by Tyler Austin on 10/19/25.
//

import ARKit
import AVFoundation

final class ARFaceCameraService: CameraService {
    private let bufferStream = AsyncStreamBridge<CVPixelBuffer>()
    var pixelBufferStream: AsyncStream<CVPixelBuffer> { bufferStream.stream }
    var previewLayer: AVCaptureVideoPreviewLayer? { nil } // ARKit view uses ARSCNView, handled by SwiftUI representable

    private var session: ARSession?

    func start() async throws {
        guard ARFaceTrackingConfiguration.isSupported else {
            throw NSError(domain: "ARFaceCameraService", code: -1, userInfo: [NSLocalizedDescriptionKey: "ARFaceTracking not supported"])
        }
        // Minimal stub to keep compile; you can swap to ARSCNView delegate later:
        // For now, we don't stream frames; coordinator will fall back to System camera if not using ARKit preview.
    }

    func stop() {
        session?.pause()
        bufferStream.finish()
    }
}


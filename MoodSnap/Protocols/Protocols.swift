//
//  Protocols.swift
//  MoodSnap
//
//  Created by Tyler Austin on 11/1/25.
//

import AVFoundation
import CoreVideo

public protocol CameraService: AnyObject, Sendable {
    var pixelBufferStream: AsyncStream<CVPixelBuffer> { get }
    func start() async throws
    func stop()
    var previewLayer: AVCaptureVideoPreviewLayer? { get } // for System camera
}

public protocol EmotionInferencing: AnyObject, Sendable {
    func start() async
    func stop()
    func classify(pixelBuffer: CVPixelBuffer) async -> EmotionPrediction?
}

public protocol SpeechTranscribing: AnyObject, Sendable {
    var utterancesStream: AsyncStream<Utterance> { get }
    func start() async throws
    func stop()
}

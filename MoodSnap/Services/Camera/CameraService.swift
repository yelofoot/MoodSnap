//
//  CameraService.swift
//  MoodSnap
//
//  Created by Tyler Austin on 11/1/25.
//

import AVFoundation
import CoreVideo

// Simple utility: a thread-safe async stream continuations holder
final class CVPixelBufferStream {
    private var continuation: AsyncStream<CVPixelBuffer>.Continuation?
    private let streamStorage: AsyncStream<CVPixelBuffer>

    init() {
        var cont: AsyncStream<CVPixelBuffer>.Continuation!
        self.streamStorage = AsyncStream<CVPixelBuffer> { c in cont = c }
        self.continuation = cont
    }

    var stream: AsyncStream<CVPixelBuffer> { streamStorage }

    func yield(_ buffer: CVPixelBuffer) {
        continuation?.yield(buffer)
    }

    func finish() {
        continuation?.finish()
    }
}

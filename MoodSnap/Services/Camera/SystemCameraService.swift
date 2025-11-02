//
//  SystemCameraService.swift
//  MoodSnap
//
//  Created by Tyler Austin on 10/19/25.
//

import Foundation
import Speech
import AVFoundation

final class SpeechTranscriptService: NSObject, SpeechTranscribing {
    private let audioEngine = AVAudioEngine()
    private let recognizer = SFSpeechRecognizer()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let utteranceStream = AsyncStreamBridge<Utterance>()

    var utterancesStream: AsyncStream<Utterance> { utteranceStream.stream }

    func start() async throws {
        let status = await SFSpeechRecognizer.requestAuthorization()
        guard status == .authorized else {
            throw NSError(domain: "SpeechTranscriptService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Speech permission denied"])
        }

        try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
        try AVAudioSession.sharedInstance().setActive(true)

        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        task = recognizer?.recognitionTask(with: request!, resultHandler: { [weak self] result, error in
            if let r = result {
                let text = r.bestTranscription.formattedString
                let isFinal = r.isFinal
                let utter = Utterance(text: text, timestamp: Date())
                self?.utteranceStream.yield(utter)
                if isFinal {
                    // could mark final; for now we just stream
                }
            }
            if error != nil {
                self?.stop()
            }
        })
    }

    func stop() {
        task?.cancel()
        task = nil
        request?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        if audioEngine.isRunning { audioEngine.stop() }
        utteranceStream.finish()
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

// Utility bridge for AsyncStream of value type
final class AsyncStreamBridge<T> {
    private var continuation: AsyncStream<T>.Continuation!
    let stream: AsyncStream<T>
    init() {
        self.stream = AsyncStream<T> { cont in
            self.continuation = cont
        }
    }
    func yield(_ value: T) { continuation.yield(value) }
    func finish() { continuation.finish() }
}

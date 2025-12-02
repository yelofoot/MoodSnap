//
//  SpeechTranscriptService.swift
//  MoodSnap
//
//  Created by Tyler Austin on 10/19/25.
//

import Foundation
import AVFoundation
import Speech

final class SpeechTranscriptService: NSObject, SpeechTranscribing {
    private let utteranceBridge = AsyncStreamBridge<Utterance>()
    var utterancesStream: AsyncStream<Utterance> { utteranceBridge.stream }

    private let recognizer = SFSpeechRecognizer()
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func start() async throws {
        let auth = await requestSpeechAuthorization()
        guard auth == .authorized else {
            throw NSError(domain: "SpeechTranscriptService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Speech recognition not authorized"])
        }

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? session.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        // Ensure any prior task is cancelled before starting a new one
        recognitionTask?.cancel()
        recognitionTask = nil

        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            if let result = result {
                let text = result.bestTranscription.formattedString
                self.utteranceBridge.yield(Utterance(text: text))
            }
            if let error = error {
                // End on error
                self.stop()
                print("Speech recognition error: \(error)")
            }
        }

        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, when in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    func stop() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
        // Do not finish the utterance stream; we want to reuse it across sessions.
    }

    private func requestSpeechAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status)
            }
        }
    }
}

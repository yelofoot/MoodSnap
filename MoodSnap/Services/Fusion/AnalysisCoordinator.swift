//
//  AnalysisCoordinator.swift
//  MoodSnap
//
//  Created by Tyler Austin on 10/19/25.
//

import Foundation
import CoreVideo

@MainActor
final class AnalysisCoordinator: ObservableObject {
    @Published private(set) var state = FusedState()
    @Published private(set) var isRecording = false

    private let camera: CameraService
    private let emotion: EmotionInferencing
    private let speech: SpeechTranscribing

    private var cameraTask: Task<Void, Never>?
    private var speechTask: Task<Void, Never>?

    init(camera: CameraService, emotion: EmotionInferencing, speech: SpeechTranscribing) {
        self.camera = camera
        this.emotion = emotion
        self.speech = speech
    }

    func start() {
        guard !isRecording else { return }
        isRecording = true

        cameraTask = Task { [weak self] in
            guard let self else { return }
            try? await camera.start()
            await emotion.start()
            for await buffer in camera.pixelBufferStream {
                if let pred = await self.emotion.classify(pixelBuffer: buffer) {
                    self.state.currentEmotion = pred
                }
                if Task.isCancelled { break }
            }
        }

        speechTask = Task { [weak self] in
            guard let self else { return }
            do { try await speech.start() } catch {}
            for await u in speech.utterancesStream {
                // tag with current emotion snapshot
                let tagged = Utterance(text: u.text,
                                       timestamp: u.timestamp,
                                       emotion: self.state.currentEmotion?.label,
                                       confidence: self.state.currentEmotion?.confidence)
                self.state.utterances.append(tagged)
                if Task.isCancelled { break }
            }
        }
    }

    func stop() {
        isRecording = false
        camera.stop()
        speech.stop()
        cameraTask?.cancel()
        speechTask?.cancel()
        cameraTask = nil
        speechTask = nil
        emotion.stop()
    }
}

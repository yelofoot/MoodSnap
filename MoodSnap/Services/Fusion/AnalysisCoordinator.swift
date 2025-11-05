//
//  AnalysisCoordinator.swift
//  MoodSnap
//
//  Created by Tyler Austin on 10/19/25.
//

import Foundation
import CoreVideo
import Combine

@MainActor
final class AnalysisCoordinator: ObservableObject {
    @Published private(set) var state = FusedState()
    @Published private(set) var isRecording = false
    @Published var lastErrorMessage: String? = nil

    private let camera: CameraService
    private let emotion: EmotionInferencing
    private let speech: SpeechTranscribing

    private var cameraTask: Task<Void, Never>?
    private var speechTask: Task<Void, Never>?

    init(camera: CameraService, emotion: EmotionInferencing, speech: SpeechTranscribing) {
        self.camera = camera
        self.emotion = emotion
        self.speech = speech
    }

    func start() {
        guard !isRecording else { return }
        isRecording = true

        cameraTask = Task { [weak self] in
            guard let self else { return }
            do { try await camera.start() } catch {
                await MainActor.run { [weak self] in
                    self?.lastErrorMessage = (error as NSError).localizedDescription
                    self?.isRecording = false
                }
                return
            }
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
            do { try await speech.start() } catch {
                await MainActor.run { [weak self] in
                    self?.lastErrorMessage = (error as NSError).localizedDescription
                    self?.isRecording = false
                }
                return
            }
            for await u in speech.utterancesStream {
                // tag with current emotion snapshot
                let tagged = Utterance(text: u.text,
                                       timestamp: u.timestamp,
                                       emotion: self.state.currentEmotion?.label,
                                       confidence: self.state.currentEmotion?.confidence)
                self.state.utterances.append(tagged)
                if self.state.utterances.count > 500 {
                    self.state.utterances.removeFirst(self.state.utterances.count - 500)
                }
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


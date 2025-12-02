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

    func startPreviewIfNeeded() {
        // Start camera + emotion inference once when the camera screen appears.
        guard cameraTask == nil else { return }

        cameraTask = Task { [weak self] in
            guard let self else { return }
            do { try await camera.start() } catch {
                await MainActor.run { [weak self] in
                    self?.lastErrorMessage = (error as NSError).localizedDescription
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
    }

    func startRecording() {
        guard !isRecording else { return }
        isRecording = true

        // Start speech only when recording.
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

    func stopRecording() {
        guard isRecording else { return }
        isRecording = false
        speech.stop()
        speechTask?.cancel()
        speechTask = nil
    }

    func stopAll() {
        // Stop recording if active
        if isRecording { stopRecording() }
        // Stop camera + emotion
        camera.stop()
        cameraTask?.cancel()
        cameraTask = nil
        emotion.stop()
    }

    func resetAll() {
        // Stop any ongoing work
        stopAll()
        // Clear published state for a clean demo restart
        state = FusedState()
        lastErrorMessage = nil
        isRecording = false
    }
}

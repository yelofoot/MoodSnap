//
//  AppContainer.swift
//  MoodSnap
//
//  Created by Tyler Austin on 11/2/25.
//

import Foundation
import AVFoundation

/// Simple dependency container for wiring up services used by the app.
final class AppContainer {
    let systemCamera: SystemCameraService
    let emotion: EmotionInferencing
    let speech: SpeechTranscribing

    init() {
        // Default to the system camera; you can swap to ARFaceCameraService later.
        self.systemCamera = SystemCameraService()
        self.emotion = FaceEmotionService()
        self.speech = SpeechTranscriptService()
    }

    func makeCoordinator() -> AnalysisCoordinator {
        AnalysisCoordinator(camera: systemCamera, emotion: emotion, speech: speech)
    }
}

# MoodSnap

MoodSnap is a SwiftUI prototype for capturing short spoken moments while tagging each utterance with the emotion detected from the camera feed. It pairs live speech transcription with Core ML facial emotion inference so you can review what was said alongside how the speaker felt.

## Features
- **Camera-driven emotion HUD:** Streams frames from the device camera and runs a Core ML classifier (configurable in `ModelConfig`) to surface the current emotion label and confidence.
- **Live speech transcription:** Uses `SFSpeechRecognizer` to transcribe audio while recording, tagging each utterance with the latest detected emotion.
- **Recording workflow:** Welcome screen, swipeable tab navigation, and a record/stop flow that starts and stops speech capture while keeping the emotion HUD running.
- **Transcript review:** View the running list of utterances with their timestamps, inferred emotions, and confidences.
- **Restart + cleanup:** Reset all state when the app backgrounds or when the user taps restart, clearing camera, speech, and fused state.

## Project structure
- `App/` – App entry point (`MoodSnapApp`) and container wiring (`AppContainer`, `ContentView`, navigation shell).
- `Services/` – Camera access (`SystemCameraService`/`ARFaceCameraService`), facial emotion inference (`FaceEmotionService`), speech transcription (`SpeechTranscriptService`), and fusion logic (`AnalysisCoordinator`).
- `Views/` – SwiftUI screens for the welcome flow, recording HUD, transcript display, and supporting UI components.
- `Models/` – Data models for fused emotion + speech state, predictions, and utterances.
- `Configuration/ModelConfig.swift` – Configure the Core ML model resource name (default `CNNEmotions.mlmodelc`).
- `Resources/` – Localized strings and emotion label resources.

## Requirements
- Xcode 15+ with the iOS 17 SDK.
- Real device with camera and microphone access; speech recognition permission must be granted.
- A compiled Core ML emotion model placed in the app bundle matching `ModelConfig.emotionModelResourceName`.

## Running the app
1. Open `MoodSnap.xcodeproj` in Xcode.
2. Ensure your Core ML model is added to the target with the expected name (e.g., `CNNEmotions.mlmodel` so it compiles to `CNNEmotions.mlmodelc`).
3. Select a physical iOS device target (simulator lacks camera/mic + speech recognition for this workflow).
4. Build and run. Grant camera, microphone, and speech recognition permissions when prompted.
5. Swipe to the center tab to view the camera HUD, tap **Record** to start transcribing, and review tagged utterances in the Transcript tab.

## Notes
- The history tab is a placeholder for future saved recordings.
- `ARFaceCameraService` is stubbed; the app currently uses `SystemCameraService` for the live preview.

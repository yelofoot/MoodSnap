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
- A physical iOS device with camera and microphone access (the simulator does not support the full workflow).
- Speech recognition permission enabled on the device (you will be prompted on first run).
- A compiled Core ML emotion model placed in the app bundle matching `ModelConfig.emotionModelResourceName`.

## Installation
1. Clone the repository and open `MoodSnap.xcodeproj` in Xcode.
2. In **Signing & Capabilities**, set your development team and bundle identifier.
3. Add your Core ML model to the target so it compiles to `ModelConfig.emotionModelResourceName` (default `CNNEmotions.mlmodelc`). Update `MoodSnap/Configuration/ModelConfig.swift` if you use a different name.
4. (Optional) Update localized strings or emotion label resources under `MoodSnap/Resources` to match your model.

## Running the app
1. Select a physical iOS device target. Ensure camera, microphone, and speech recognition are available and enabled in Settings.
2. Build and run from Xcode. Grant permissions when prompted.
3. Swipe to the center tab to view the camera HUD, tap **Record** to start transcribing, and review tagged utterances in the Transcript tab.

## Notes
- The history tab is a placeholder for future saved recordings.
- `ARFaceCameraService` is stubbed; the app currently uses `SystemCameraService` for the live preview.

## Contributing
We welcome improvements and experiments to grow the prototype.

### Development setup
- Use Xcode 15+ with the iOS 17 SDK and run on a physical device to exercise the camera, microphone, and speech workflows.
- Configure code signing and install your Core ML model as described in **Installation** so the app can build and run locally.
- Keep the Swift files grouped by their existing folders (`App/`, `Services/`, `Views/`, `Models/`, and `Configuration/`) to preserve the project structure.

### Branching and workflow
- Create a feature branch from `main` for each change and open pull requests early for feedback.
- Keep changes scoped and favor small, descriptive commits that explain _what_ changed and _why_.
- Include screenshots or screen recordings in PRs when you modify UI components to help reviewers understand the change.

### Testing and verification
- Run the app on device to verify speech transcription, camera preview, and emotion overlay still function end-to-end.
- If you add a new Core ML model or update `ModelConfig`, confirm the model loads successfully at launch and displays emotion labels as expected.
- Manually exercise the recording flow (record, stop, restart) and transcript review to ensure no regressions.

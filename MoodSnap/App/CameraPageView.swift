import SwiftUI

struct CameraPageView: View {
    @ObservedObject var coordinator: AnalysisCoordinator
    let systemCamera: SystemCameraService

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Camera preview layer from the SystemCameraService
            CameraPreviewView(layer: systemCamera.previewLayer)
                .ignoresSafeArea()
                .background(Color.black)

            // Live emotion HUD (always running while on camera screen)
            Group {
                if let pred = coordinator.state.currentEmotion {
                    EmotionHUD(label: pred.label, confidence: pred.confidence)
                        .padding(.top, 50)
                        .padding(.leading, 16)
                } else {
                    EmotionHUD(label: nil, confidence: nil)
                        .padding(.top, 50)
                        .padding(.leading, 16)
                }
            }

            VStack {
                Spacer()
                // Record/Stop control toggles ONLY speech transcription
                Button(action: {
                    if coordinator.isRecording {
                        coordinator.stopRecording()
                    } else {
                        coordinator.startRecording()
                    }
                }) {
                    Image(systemName: coordinator.isRecording ? "stop.circle.fill" : "record.circle.fill")
                        .font(.system(size: 64))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(coordinator.isRecording ? .red : .green)
                        .shadow(radius: 4)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear { coordinator.startPreviewIfNeeded() }
        .onDisappear { coordinator.stopAll() }
    }
}

// Preview placeholder that avoids referencing final runtime services.
#if DEBUG
private struct CameraPageView_PreviewPlaceholder: View {
    @State private var isRecording = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Spacer()
                Button(action: { isRecording.toggle() }) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "record.circle.fill")
                        .font(.system(size: 64))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(isRecording ? .red : .green)
                        .shadow(radius: 4)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview("Camera Page Placeholder") {
    CameraPageView_PreviewPlaceholder()
}
#endif

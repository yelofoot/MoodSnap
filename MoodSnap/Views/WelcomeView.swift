import SwiftUI

struct WelcomeView: View {
    var onContinue: () -> Void
    var onRestart: (() -> Void)? = nil

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.blue.opacity(0.25), Color.purple.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 56))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.primary)
                    Text("Welcome to MoodSnap")
                        .font(.largeTitle).bold()
                        .multilineTextAlignment(.center)
                    Text("See how you feel while you speak. Record short moments and review your transcript with emotion context.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Label("Live emotion HUD from the camera", systemImage: "camera.viewfinder")
                    Label("Tap to record or stop at any time", systemImage: "record.circle")
                    Label("Finish & Save to store a transcript", systemImage: "tray.and.arrow.down")
                }
                .font(.headline)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)

                Button(action: onContinue) {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal)

                if let onRestart {
                    Button(action: onRestart) {
                        Label("Restart App", systemImage: "arrow.clockwise.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .padding(.horizontal)
                }

                Spacer(minLength: 0)
            }
            .padding(.top, 40)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    WelcomeView(onContinue: {}, onRestart: {})
}

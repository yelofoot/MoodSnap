import SwiftUI

struct ContentView: View {
    let container: AppContainer

    @State private var selectedIndex: Int = 1 // center on camera
    @StateObject private var coordinator: AnalysisCoordinator
    @State private var showWelcome: Bool = true
    @State private var shouldShowChat: Bool = false
    @State private var chatTranscript: String? = nil
    @State private var chatEmotion: EmotionPrediction? = nil
    @Environment(\.scenePhase) private var scenePhase

    init(container: AppContainer) {
        self.container = container
        _coordinator = StateObject(wrappedValue: container.makeCoordinator())
    }

    var body: some View {
        TabView(selection: $selectedIndex) {
            // Left: History placeholder
            NavigationStack {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("History coming soon")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .navigationTitle("History")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tag(0)

            // Center: Camera (RecordView for demo)
            NavigationStack {
                RecordView(coordinator: coordinator, systemCamera: container.systemCamera) { transcript, emotion in
                    // Trigger navigation to the chat view once recording stops successfully.
                    chatTranscript = transcript
                    chatEmotion = emotion
                    shouldShowChat = true
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            coordinator.resetAll()
                            showWelcome = true
                        } label: {
                            Label("Restart", systemImage: "arrow.clockwise")
                        }
                        .accessibilityLabel("Restart App")
                    }
                }
                .background {
                    NavigationLink(isActive: $shouldShowChat) {
                        ChatView(initialTranscript: chatTranscript, initialEmotion: chatEmotion)
                    } label: {
                        EmptyView()
                    }
                    .hidden()
                }
            }
            .tag(1)

            // Right: Transcript
            NavigationStack {
                TranscriptView(coordinator: coordinator)
                    .navigationTitle("Transcript")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                coordinator.resetAll()
                                showWelcome = true
                            } label: {
                                Label("Restart", systemImage: "arrow.clockwise")
                            }
                            .accessibilityLabel("Restart App")
                        }
                    }
            }
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $showWelcome) {
            WelcomeView(
                onContinue: {
                    showWelcome = false
                },
                onRestart: {
                    coordinator.resetAll()
                    showWelcome = true
                }
            )
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                coordinator.resetAll()
                showWelcome = true
            }
        }
    }
}


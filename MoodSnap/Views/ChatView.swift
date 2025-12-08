import SwiftUI

/// Conversation view that talks to OpenAI's Chat Completions API.
struct ChatView: View {
    @State private var messages: [ChatMessage]
    @State private var inputText: String = ""
    @State private var isSending: Bool = false
    @State private var errorMessage: String? = nil

    private let chatService = ChatService()
    private let initialTranscript: String?
    private let initialEmotion: EmotionPrediction?

    init(initialTranscript: String?, initialEmotion: EmotionPrediction?) {
        self.initialTranscript = initialTranscript
        self.initialEmotion = initialEmotion

        var seeded: [ChatMessage] = [
            ChatMessage(role: .assistant, content: "Let's reflect on your latest recording. Ask me anything!")
        ]

        if let transcript = initialTranscript, !transcript.isEmpty {
            let summaryPrompt = "Transcript from your recording:\n\(transcript)"
            seeded.append(ChatMessage(role: .system, content: summaryPrompt))
        }

        if let label = initialEmotion?.label, let confidence = initialEmotion?.confidence {
            let emotionNote = String(format: "Detected emotion: %@ (%.0f%%)", label, confidence * 100)
            seeded.append(ChatMessage(role: .system, content: emotionNote))
        }

        _messages = State(initialValue: seeded)
    }

    var body: some View {
        VStack(spacing: 12) {
            List(messages) { message in
                VStack(alignment: .leading, spacing: 4) {
                    Text(title(for: message.role))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(message.content)
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            HStack(spacing: 8) {
                TextField("Ask something about the recording...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isSending)
                Button(action: sendMessage) {
                    if isSending {
                        ProgressView()
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            }
            .padding()
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func title(for role: ChatMessage.Role) -> String {
        switch role {
        case .system: return "Context"
        case .assistant: return "ChatGPT"
        case .user: return "You"
        }
    }

    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newMessage = ChatMessage(role: .user, content: trimmed)
        messages.append(newMessage)
        inputText = ""
        errorMessage = nil
        isSending = true

        Task {
            do {
                let reply = try await chatService.send(messages: messages)
                await MainActor.run {
                    messages.append(reply)
                    isSending = false
                }
            } catch {
                await MainActor.run {
                    isSending = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(initialTranscript: "Hello world", initialEmotion: EmotionPrediction(label: "Happy", confidence: 0.92))
    }
}

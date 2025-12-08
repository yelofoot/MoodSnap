import Foundation

/// Lightweight chat message model for OpenAI and UI rendering.
struct ChatMessage: Identifiable, Equatable {
    enum Role: String {
        case system
        case user
        case assistant
    }

    let id = UUID()
    let role: Role
    let content: String
}

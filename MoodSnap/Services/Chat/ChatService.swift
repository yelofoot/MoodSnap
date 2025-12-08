import Foundation

/// Minimal client for sending chat prompts to the OpenAI Chat Completions API.
struct ChatService {
    enum ChatError: LocalizedError {
        case missingAPIKey
        case invalidResponse
        case failedRequest(Int)

        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "Missing OPENAI_API_KEY in environment."
            case .invalidResponse:
                return "Received an invalid response from the OpenAI API."
            case .failedRequest(let code):
                return "OpenAI API returned status code \(code)."
            }
        }
    }

    func send(messages: [ChatMessage]) async throws -> ChatMessage {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !apiKey.isEmpty else {
            throw ChatError.missingAPIKey
        }

        let payload = ChatCompletionRequest(
            model: "gpt-3.5-turbo",
            messages: messages.map { .init(role: $0.role.rawValue, content: $0.content) }
        )

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw ChatError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw ChatError.failedRequest(http.statusCode) }

        let decoded = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let choice = decoded.choices.first else { throw ChatError.invalidResponse }
        return ChatMessage(role: .assistant, content: choice.message.content)
    }
}

private struct ChatCompletionRequest: Encodable {
    struct PayloadMessage: Encodable {
        let role: String
        let content: String
    }

    let model: String
    let messages: [PayloadMessage]
}

private struct ChatCompletionResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let role: String
            let content: String
        }
        let index: Int
        let message: Message
    }

    let choices: [Choice]
}

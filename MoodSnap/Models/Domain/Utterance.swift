//
//  Utterance.swift
//  MoodSnap
//
//  Created by Tyler Austin on 10/27/25.
//

import Foundation

public struct Utterance: Identifiable, Sendable, Equatable {
    public let id = UUID()
    public let text: String
    public let timestamp: Date
    public let emotion: String?
    public let confidence: Float?

    public init(text: String,
                timestamp: Date = .init(),
                emotion: String? = nil,
                confidence: Float? = nil) {
        self.text = text
        self.timestamp = timestamp
        self.emotion = emotion
        self.confidence = confidence
    }
}

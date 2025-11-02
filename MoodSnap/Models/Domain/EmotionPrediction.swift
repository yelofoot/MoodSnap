//
//  EmotionScore.swift
//  MoodSnap
//
//  Created by Tyler Austin on 10/27/25.
//

import Foundation

public struct EmotionPrediction: Sendable, Equatable {
    public let label: String
    public let confidence: Float
    public let timestamp: Date

    public init(label: String, confidence: Float, timestamp: Date = .init()) {
        self.label = label
        self.confidence = confidence
        self.timestamp = timestamp
    }
}

//
//  FusedState.swift
//  MoodSnap
//
//  Created by Tyler Austin on 11/1/25.
//

import Foundation

public struct FusedState: Sendable, Equatable {
    public var currentEmotion: EmotionPrediction?
    public var utterances: [Utterance]

    public init(currentEmotion: EmotionPrediction? = nil,
                utterances: [Utterance] = []) {
        self.currentEmotion = currentEmotion
        self.utterances = utterances
    }
}

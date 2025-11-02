//
//  TranscriptView.swift
//  MoodSnap
//
//  Created by Tyler Austin on 10/19/25.
//

import SwiftUI

struct TranscriptView: View {
    @ObservedObject var coordinator: AnalysisCoordinator

    var body: some View {
        List(coordinator.state.utterances) { u in
            VStack(alignment: .leading, spacing: 4) {
                Text(u.text)
                    .font(.body)
                HStack(spacing: 12) {
                    if let e = u.emotion {
                        Label(e, systemImage: "face.smiling")
                    }
                    if let c = u.confidence {
                        Text(String(format: "%.0f%%", c * 100))
                    }
                    Text(u.timestamp, style: .time)
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)
        }
        .navigationTitle("Transcript")
    }
}

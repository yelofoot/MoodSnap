//
//  EmotionHUD.swift
//  MoodSnap
//
//  Created by Tyler Austin on 10/19/25.
//

import SwiftUI

struct EmotionHUD: View {
    let label: String?
    let confidence: Float?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.5))
            HStack(spacing: 8) {
                Text(label ?? "—")
                    .font(.headline)
                    .foregroundColor(.white)
                if let c = confidence {
                    Text(String(format: "%.0f%%", c * 100))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .fixedSize()
        .padding(8)
    }
}

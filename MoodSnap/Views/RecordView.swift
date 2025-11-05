//
//  RecordView.swift
//  MoodSnap
//
//  Created by Tyler Austin on 10/19/25.
//

import SwiftUI

struct RecordView: View {
    @StateObject var coordinator: AnalysisCoordinator
    let systemCamera: SystemCameraService // for preview layer access
    @State private var showErrorAlert = false

    var body: some View {
        ZStack(alignment: .top) {
            CameraPreviewView(layer: systemCamera.previewLayer)
                .ignoresSafeArea()

            EmotionHUD(label: coordinator.state.currentEmotion?.label,
                       confidence: coordinator.state.currentEmotion?.confidence)
                .padding(.top, 48)
        }
        .overlay(alignment: .bottom) {
            HStack(spacing: 20) {
                Button(action: { coordinator.start() }) {
                    Label("Start", systemImage: "record.circle")
                }
                .buttonStyle(.borderedProminent)

                Button(role: .destructive, action: { coordinator.stop() }) {
                    Label("Stop", systemImage: "stop.fill")
                }
                .buttonStyle(.bordered)
            }
            .padding(.bottom, 32)
        }
        .navigationTitle("Record")
        .onReceive(coordinator.$lastErrorMessage) { msg in
            showErrorAlert = (msg != nil)
        }
        .alert("Error", isPresented: $showErrorAlert, actions: {
            Button("OK") { coordinator.lastErrorMessage = nil }
        }, message: {
            Text(coordinator.lastErrorMessage ?? "Unknown error")
        })
    }
}

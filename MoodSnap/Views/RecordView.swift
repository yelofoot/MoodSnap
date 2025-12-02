//
//  RecordView.swift
//  MoodSnap
//
//  Created by Tyler Austin on 10/19/25.
//

import SwiftUI

struct RecordView: View {
    @ObservedObject var coordinator: AnalysisCoordinator
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
            VStack(spacing: 16) {
                Button(action: {
                    if coordinator.isRecording {
                        coordinator.stopAll()
                    } else {
                        coordinator.startPreviewIfNeeded()
                        coordinator.startRecording()
                    }
                }) {
                    Image(systemName: coordinator.isRecording ? "stop.circle.fill" : "record.circle.fill")
                        .font(.system(size: 72))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(coordinator.isRecording ? .red : .green)
                        .shadow(radius: 4)
                        .accessibilityLabel(coordinator.isRecording ? "Stop Recording" : "Start Recording")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 32)
        }
        .navigationTitle("Record")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            coordinator.startPreviewIfNeeded()
        }
        .onDisappear {
            coordinator.stopAll()
        }
        .onChange(of: coordinator.lastErrorMessage) { msg in
            showErrorAlert = (msg != nil)
        }
        .alert("Error", isPresented: $showErrorAlert, actions: {
            Button("OK") { coordinator.lastErrorMessage = nil }
        }, message: {
            Text(coordinator.lastErrorMessage ?? "Unknown error")
        })
    }
}

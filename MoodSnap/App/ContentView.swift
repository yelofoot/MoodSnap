//
//  ContentView.swift
//  MoodSnap
//
//  Created by Tyler Austin on 10/19/25.
//

import SwiftUI

struct ContentView: View {
    let container: AppContainer

    @State private var isPrepared = false
    @StateObject private var coordinator: AnalysisCoordinator

    init(container: AppContainer) {
        self.container = container
        // coordinator uses System camera by default; AR can swap later
        _coordinator = StateObject(wrappedValue: container.makeCoordinator())
    }

    var body: some View {
        TabView {
            NavigationStack {
                RecordView(coordinator: coordinator,
                           systemCamera: container.systemCamera)
            }
            .tabItem { Label("Record", systemImage: "camera.fill") }

            NavigationStack {
                TranscriptView(coordinator: coordinator)
            }
            .tabItem { Label("Transcript", systemImage: "text.bubble.fill") }
        }
    }
}

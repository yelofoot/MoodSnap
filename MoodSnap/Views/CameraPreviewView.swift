//
//  CameraPreviewView.swift
//  MoodSnap
//
//  Created by Tyler Austin on 10/19/25.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    let layer: AVCaptureVideoPreviewLayer?

    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        v.backgroundColor = .black
        guard let layer else { return v }
        layer.frame = v.bounds
        layer.videoGravity = .resizeAspectFill
        v.layer.addSublayer(layer)
        return v
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let layer else { return }
        layer.frame = uiView.bounds
        if layer.superlayer == nil {
            uiView.layer.addSublayer(layer)
        }
    }
}

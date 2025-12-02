//
//  FaceEmotionService.swift
//  MoodSnap
//
//  Created by Tyler Austin on 10/19/25.
//

import Vision
import CoreML
import CoreVideo
import Foundation

final class FaceEmotionService: EmotionInferencing {
    private var request: VNCoreMLRequest?
    private var throttling = false

    func start() async {
        // Load compiled CoreML model dynamically using configured resource name
        let name = ModelConfig.emotionModelResourceName
        if let url = Bundle.main.url(forResource: name, withExtension: "mlmodelc") {
            print("FaceEmotionService: Found model resource at \(url.lastPathComponent)")
            do {
                let mlModel = try MLModel(contentsOf: url)
                let model = try VNCoreMLModel(for: mlModel)
                let req = VNCoreMLRequest(model: model)
                print("FaceEmotionService: Model loaded and VNCoreMLRequest configured")
                req.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
                self.request = req
            } catch {
                self.request = nil
                print("FaceEmotionService: Failed to load model '\(name)': \(error)")
            }
        } else {
            self.request = nil
            print("FaceEmotionService: Model not found in bundle: \(name).mlmodelc")
        }
    }

    func stop() {
        request = nil
    }

    func classify(pixelBuffer: CVPixelBuffer) async -> EmotionPrediction? {
        guard let request = request, throttling == false else { return nil }
        throttling = true
        defer {
            // simple throttle (~15 fps -> process every ~4th frame)
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.07) { [weak self] in
                self?.throttling = false
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([request])
            if let results = request.results as? [VNClassificationObservation],
               let top = results.first {
                // print("Emotion: \(top.identifier) (\(Int(top.confidence * 100))%)")
                return EmotionPrediction(label: top.identifier, confidence: top.confidence)
            }
        } catch {
            return nil
        }
        return nil
    }
}


//
//  FaceEmotionService.swift
//  MoodSnap
//
//  Created by Tyler Austin on 10/19/25.
//

import Vision
import CoreML
import CoreVideo

final class FaceEmotionService: EmotionInferencing {
    private var request: VNCoreMLRequest?
    private var throttling = false

    func start() async {
        // Generate model class after adding CNNEemotions.mlmodel to project
        // Replace CNNEemotions() with your generated model type if different
        if let model = try? VNCoreMLModel(for: CNNEemotions().model) {
            let req = VNCoreMLRequest(model: model)
            req.imageCropAndScaleOption = .centerCrop
            self.request = req
        } else {
            self.request = nil
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
                return EmotionPrediction(label: top.identifier, confidence: top.confidence)
            }
        } catch {
            return nil
        }
        return nil
    }
}

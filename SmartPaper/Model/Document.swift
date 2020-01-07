//
//  Document.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 25.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import SwiftUI
import Combine
import Vision

struct Document: Identifiable, Hashable {
    
    var image: UIImage
    
    let id: UUID
    
    let taken: Date
    
    var shouldBeRemoved = false
    
    /// The saturation of the image. Default value is 1.0
    var saturation: Double
    
    /// The brightness of the image. Default value is 0.0. The maximum brightness is reached with the value 1.0 and the minimum with -1.0.
    var brightness: Double
    
    var displayedImage: some View {
        return Image(uiImage: image)
            .resizable()
            .saturation(saturation)
            .brightness(brightness)
    }
    
    var adjustedImage: UIImage {
        if saturation == 1 && brightness == 0 {
            return image
        }
        
        if let adjusted = image
            .adjustedBrightness(by: CGFloat(brightness))?
            .adjustedSaturation(by: CGFloat(saturation)) {
            return adjusted
        }
        
        return image
    }
    
    private (set) lazy var text = findText()
    
    typealias TextBox = (text: String, box: CGRect)
    
    typealias TextFindingResult = (byLine: [Snippet], merged: [Snippet])
    
    init(image: UIImage, date: Date, saturation: Double = 1.0, brightness: Double = 0.0, id: UUID = UUID()) {
        self.image = image
        self.taken = date
        self.saturation = saturation
        self.brightness = brightness
        self.id = id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(taken)
        hasher.combine(saturation)
        hasher.combine(brightness)
    }
    
    private func findText() -> AnyPublisher<TextFindingResult, Never> {
        Future<TextFindingResult, Never> { promise in
            var snippets = [Snippet]()
            var mergedSnippets = [Snippet]()
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    fatalError()
                }
                
                mergedSnippets = self.concatObservationResults(observations)
                observations.forEach { observation in
                    snippets += observation.topCandidates(10).compactMap { candidate in
                        guard candidate.confidence >= 0.4 else {
                            return nil
                        }
                        
                        return Snippet(content: candidate.string, date: Date())
                    }
                }
            }
            
            with(request) {
                let languages = try! VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate,
                                                                                          revision: request.revision)
                
                $0.recognitionLevel = .accurate
                $0.usesLanguageCorrection = false
                $0.recognitionLanguages = languages
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                guard let image = self.adjustedImage.cgImage else {
                    fatalError()
                }
                
                let handler = VNImageRequestHandler(cgImage: image, options: [:])
                try? handler.perform([request])
                let filtered = self.filter(snippets: snippets)
                promise(.success((byLine: filtered, merged: mergedSnippets)))
            }
        }.eraseToAnyPublisher()
    }
    
    private func concatObservationResults(_ observations: [VNRecognizedTextObservation]) -> [Snippet] {
        let recognizedText = observations.flatMap { $0.topCandidates(10) }.filter { $0.confidence >= 0.4 }
        let size = adjustedImage.size
        var textBoxes = [TextBox]()
        let scalePoint = { (point: CGPoint) -> CGPoint in
            point.scalled(width: size.width, height: size.height)
        }
        
        for text in recognizedText {
            guard let box = try? text.boundingBox(for: text.string.fullRange) else {
                continue
            }
            
            let rect = CGRect(points: (scalePoint(box.bottomLeft),
                                       scalePoint(box.bottomRight),
                                       scalePoint(box.topRight),
                                       scalePoint(box.topLeft)))
            
            guard let unwrappedRect = rect else {
                continue
            }
            
            textBoxes += [(box: unwrappedRect, text: text.string)]
        }
        
        return Document.combine(textBoxes: textBoxes, imageSize: size).map {
            Snippet(content: $0, date: Date())
        }
    }
    
    private func imageWithObservationResults(_ observations: [VNRecognizedTextObservation]) -> UIImage {
        let recognizedText = observations.flatMap { $0.topCandidates(10) }
        let image = adjustedImage
        let size = image.size
        let scale: CGFloat = 0
        let context: CGContext
        let scalePoint = { (point: CGPoint) -> CGPoint in
            point.scalled(width: size.width, height: size.height).fliped(with: size)
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        context = UIGraphicsGetCurrentContext()!
        image.draw(at: .zero)
        
        for text in recognizedText {
            guard let box = try? text.boundingBox(for: text.string.fullRange) else {
                continue
            }
            
            context.move(to: scalePoint(box.bottomLeft))
            context.addLine(to: scalePoint(box.bottomRight))
            context.addLine(to: scalePoint(box.topRight))
            context.addLine(to: scalePoint(box.topLeft))
            context.addLine(to: scalePoint(box.bottomLeft))
            context.setLineWidth(6)
            context.setStrokeColor(UIColor.red.cgColor)
            context.closePath()
            context.strokePath()
        }
        
        return UIImage(cgImage: context.makeImage()!)
    }
    
    private func filter(snippets: [Snippet]) -> [Snippet] {
        snippets
            .filter {
                $0.content.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
            }
    }
    
    private static func combine(textBoxes: [TextBox], imageSize: CGSize) -> [String] {
        for (index, textBox) in textBoxes.enumerated() {
            guard index < textBoxes.count - 1 else {
                break
            }
            
            for (nextIndex, next) in textBoxes.enumerated() {
                
                guard next.box != textBox.box else {
                    continue
                }
                
                guard textBox.box.minY > next.box.minY else {
                    continue
                }
                
                guard next.box.overlapsHorizontally(with: textBox.box) else {
                    continue
                }
                
                let distance = textBox.box.minY - next.box.maxY
                let textHeight = textBox.box.height
                let otherTextHeight = next.box.height
                
//                #if DEBUG
//                print()
//                print("————————————", textBox.text, next.text, "————————————")
//                print("Raw Values")
//                print("Distance:", distance)
//                print("Height:", textHeight, otherTextHeight)
//                print("Relative Values")
//                print("Dist - Frame:", distance / imageSize.height)
//                print("Height - Height", textHeight / otherTextHeight)
//                print("Height - Frame", textHeight / imageSize.height, otherTextHeight / imageSize.height)
//                print("Dist - Height", distance / textHeight, distance / otherTextHeight)
//                print("————————————————————————")
//                #endif
                
                // Distance to the bottom 
                guard distance > 0 else {
                    continue
                }
                
                // Similar text heights
                guard (0.9...1.1).contains(textHeight / otherTextHeight) else {
                    continue
                }
                
                // Distance of at most 30% of the text height
                guard distance / textHeight <= 0.3 else {
                    continue
                }
                
                let newBox = (text: textBox.text + next.text, box: textBox.box + next.box)
                return combine(textBoxes: textBoxes.removing(atOffsets: [index, nextIndex]) + [newBox],
                               imageSize: imageSize)
            }
        }
        
        return textBoxes.map { $0.text }
    }
    
    static func == (lhs: Document, rhs: Document) -> Bool {
        return lhs.id == rhs.id
    }
    
}

extension Document: Codable {
    
    enum CodingKeys: String, CodingKey {
        case image, saturation, brightness, taken, id
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let image = UIImage(data: try values.decode(Data.self, forKey: .image))!
        
        self.image = image
        self.taken = try values.decode(Date.self, forKey: .taken)
        self.saturation = try values.decode(Double.self, forKey: .saturation)
        self.brightness = try values.decode(Double.self, forKey: .brightness)
        self.id = try values.decode(UUID.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(saturation, forKey: .saturation)
        try container.encode(brightness, forKey: .brightness)
        try container.encode(taken, forKey: .taken)
        try container.encode(image.pngData()!, forKey: .image)
        try container.encode(id, forKey: .id)
    }
    
}

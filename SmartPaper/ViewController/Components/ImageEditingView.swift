//
//  ImageEditingView.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 29.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import SwiftUI
import CryptoKit

struct ImageEditingView: View {
    
    @Binding var document: Document
    
    @State private var brightness: Double = 0.0
    
    @State private var saturation: Double = 0.0
    
    var body: some View {
        VStack {
            Spacer()
            Image(uiImage: document.image)
                .resizable()
                .saturation(saturation)
                .brightness(brightness)
                .aspectRatio(contentMode: .fit)
            Spacer()
            VStack(spacing: 15) {
                VStack(spacing: 5) {
                    Text("Brightness")
                        .bold()
                    Slider(value: $brightness, in: -1...1, step: 0.1)
                    
                }
                VStack(spacing: 5) {
                    Text("Saturation")
                        .bold()
                    Slider(value: $saturation, in: 0...2, step: 0.1)
                }
            }
        }
        .padding()
        .onAppear {
            self.brightness = self.document.brightness
            self.saturation = self.document.saturation
        }
        .onDisappear {
            self.document.saturation = self.saturation
            self.document.brightness = self.brightness
        }
    }
}

struct ImageEditingView_Previews: PreviewProvider {
    @State private static var document = Document(image: UIImage(named: "Sample1")!, date: Date())
    
    static var previews: some View {
        ImageEditingView(document: $document)
    }
}

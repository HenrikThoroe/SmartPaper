//
//  ScannerView.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 25.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import SwiftUI

struct ScannerView: View {
    
    @EnvironmentObject var appData: AppData
    
    @State private var documents: [Document] = []
    
//    @State private var showMediaInput = false
    
    @State private var inputSource: DocumentReader.InputSource = .camera
    
//    @State private var showSnippetView = false
    
    @State private var scannerResult: Document.TextFindingResult = (byLine: [], merged: [])
    
    @State private var processingImages: Bool = false
    
    @State private var whichSheet: Sheet = .mediaInput
    
    @State private var showSheet: Bool = false
    
    private var isEmpty: Bool {
        documents.count == 0
    }
    
    var body: some View {
        GeometryReader { metrics in
            VStack {
                self.gallery(in: metrics)
                Spacer()
                self.button(action: {
                    guard self.documents.count > 0 else {
                        return
                    }
                    
                    var processedImages = 0
                    
                    self.processingImages = true
                    self.showSheet = true
                    self.whichSheet = .snippetView
                    
                    for i in 0..<self.documents.count {
                        self.documents[i]
                            .text
                            .subscribe(on: DispatchQueue.main)
                            .sink {
                                processedImages += 1
                                self.processingImages = processedImages != self.documents.count
                                self.scannerResult.byLine += $0.byLine
                                self.scannerResult.merged += $0.merged
                                
                                if !self.processingImages && self.appData.automaticallySaveScans {
                                    DispatchQueue.main.sync {
                                        self.appData.documents += self.documents
                                        self.documents = []
                                    }
                                }
                            }
                            .cancel()
                    }
                        
                }, name: "Extract Text", image: "viewfinder", disabled: self.isEmpty)
                    .opacity(self.documents.count > 0 ? 1 : 0)
            }
            .padding(.bottom)
            .sheet(isPresented: self.$showSheet) {
                if self.whichSheet == .mediaInput {
                    DocumentReader(isShown: self.$showSheet, self.inputSource) { images in
                        self.documents += images.map { image in
                            Document(image: image, date: Date())
                        }
                    }
                } else {
                    SnippetCreationView(waiting: self.$processingImages, snippets: self.$scannerResult)
                        .environmentObject(self.appData)
                }
            }
        }
    }
    
    private func gallery(in metrics: GeometryProxy) -> some View {
        Group {
            if self.isEmpty {
                self.openButton()
            } else {
                GalleryView(data: Array(0..<self.documents.count)) { index in
                    VStack(alignment: .leading, spacing: 10) {
                        self.documents[index].displayedImage
                            .scaledToFit()
                            .cornerRadius(5)
                            .frame(minHeight: 0, maxHeight: .infinity)
                            .frame(width: metrics.size.width * 0.8, alignment: .center)
                        
                    }
                    .padding([.trailing, .leading], metrics.size.width * 0.1)
                    .padding([.top, .bottom], 20)
                }
            }
        }
    }
    
    private func openButton() -> some View {
        VStack {
            Spacer()
            
            button(action: {
                self.inputSource = .camera
                self.showSheet = true
                self.whichSheet = .mediaInput
            }, name: "Take Photo", image: "camera")
            
            button(action: {
                self.inputSource = .scanner
                self.showSheet = true
                self.whichSheet = .mediaInput
            }, name: "Scan Document", image: "viewfinder")
            
            button(action: {
                self.inputSource = .library
                self.showSheet = true
                self.whichSheet = .mediaInput
            }, name: "Import from Photo Library", image: "photo")
            
            Spacer()
        }
    }
    
    private func button(action: @escaping () -> Void, name: String, image: String, disabled: Bool = false) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: image)
                Text(name)
                    .fontWeight(.semibold)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .disabled(disabled)
            .font(.subheadline)
            .padding()
            .foregroundColor(.white)
            .background(disabled ? Color.gray : Color.blue)
            .cornerRadius(10)
            .padding(.horizontal, 20)
        }
    }
}

private extension ScannerView {
    
    enum Sheet {
        case mediaInput, snippetView
    }
    
}

struct ScannerView_Previews: PreviewProvider {
    
    static var previews: some View {
        ScannerView()
    }
}

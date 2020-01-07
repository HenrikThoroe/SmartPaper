//
//  DocumentDetailView.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 27.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import SwiftUI

struct DocumentDetailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var appData: AppData
    
    @Binding var document: Document
    
    @State private var editingMode: Bool = false
    
    @State private var removeWarning: Bool = false
    
    @State private var sharingMode: Bool = false
    
    @State private var showSnippetScreen: Bool = false
    
    @State private var scannerResult: Document.TextFindingResult = (byLine: [], merged: [])
    
    @State private var processingImage: Bool = false
    
    var body: some View {
        VStack {
            document.displayedImage
                .scaledToFit()
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
            toolbar()
        }
        .navigationBarTitle(Text(document.taken.localizedDate(using: .medium)), displayMode: .inline)
        .navigationBarItems(trailing: Button(action: self.showEditSheet, label: {
            Text("Edit")
                .sheet(isPresented: $editingMode, content: editSheet)
        }))
        .actionSheet(isPresented: $removeWarning) {
            ActionSheet(title: Text("Do you want to delete this document?"),
                        message: Text("You can't undo this step."),
                        buttons: [.cancel(),
                                  .destructive(Text("Delete"), action: self.delete)])
        }
    }
    
    private func delete() {
        presentationMode.wrappedValue.dismiss()
        document.shouldBeRemoved = true
    }
    
    private func editSheet() -> some View {
        ImageEditingView(document: $document)
    }
    
    private func toolbar() -> some View {
        HStack {
            Button(action: { self.removeWarning = true }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            Spacer()
            Button(action: {
                self.processingImage = true
                self.showSnippetScreen = true
                self.document
                    .text
                    .subscribe(on: DispatchQueue.main)
                    .sink {
                        self.processingImage = false
                        self.scannerResult = $0
                    }
                    .cancel()
            }) {
                Image(systemName: "viewfinder")
            }
            .sheet(isPresented: $showSnippetScreen) {
                SnippetCreationView(waiting: self.$processingImage, snippets: self.$scannerResult)
                    .environmentObject(self.appData)
            }
            Spacer()
            Button(action: { self.sharingMode = true }) {
                Image(systemName: "square.and.arrow.up")
            }
            .sheet(isPresented: $sharingMode) {
                ShareSheet(sharedItems: [self.document.adjustedImage])
            }
        }
        .font(.headline)
        .padding()
        .padding(.horizontal, 30)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
    }
    
    private func showEditSheet() {
        editingMode = true
    }
}

struct DocumentDetailView_Previews: PreviewProvider {
    
    @State private static var document = Document(image: UIImage(named: "Sample1")!, date: Date())
    
    @State private static var isShown = true
    
    static var previews: some View {
        DocumentDetailView(document: $document)
    }
}

//
//  DocumentListView.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 24.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import SwiftUI
import WaterfallGrid

struct DocumentListView: View {
    
    @Binding var documents: [Document]
    
    @EnvironmentObject var appData: AppData
    
    @State private var showAddAlert = false
    
    @State private var showImagePicker: Bool = false
    
    @State private var imagePickerSource: DocumentReader.InputSource = .library
    
    private var groups: [DocumentGroup] {
        documents
            .filter {
                !$0.shouldBeRemoved
            }
            .group {
                $0.taken.daysSince1970 == $1.taken.daysSince1970
            }
            .map { list in
                DocumentGroup(content: list, name: list[0].taken.localizedDate(using: .full))
            }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    ForEach(self.groups) { group in
                        VStack(alignment: .leading) {
                            Text(group.name)
                                .font(.headline)
                                .padding(.top, 30)
                                .padding(.bottom, 10)
                            WaterfallGrid(group.content) { doc in
                                NavigationLink(destination:
                                DocumentDetailView(document: self.binding(for: doc)).environmentObject(self.appData)) {
                                    doc.displayedImage
                                        .aspectRatio(contentMode: .fit)
                                }.buttonStyle(PlainButtonStyle())
                            }
                            .gridStyle(spacing: 5, scrollDirection: .horizontal)
                            .frame(minHeight: 300)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .navigationBarTitle("Documents")
            .navigationBarItems(trailing: addDocumentButton())
        }
        .sheet(isPresented: $showImagePicker) {
            DocumentReader(isShown: self.$showImagePicker, self.imagePickerSource) { images in
                self.documents += images.map { image in
                    Document(image: image, date: Date())
                }
            }
        }
        .actionSheet(isPresented: $showAddAlert) {
            DocumentReader.actionSheet(showReader: $showImagePicker, readerInput: $imagePickerSource)
        }
    }
    
    private func addDocumentButton() -> some View {
        Button(action: { self.showAddAlert.toggle() }) {
            Image(systemName: "plus")
                .font(.headline)
                .padding()
        }
    }
    
    private func binding(for document: Document) -> Binding<Document> {
        let index = documents.firstIndex { $0.id == document.id }
        return $documents[index!]
    }
    
}

private struct DocumentGroup: Hashable, Identifiable {
    let content: [Document]
    let name: String
    let id = UUID()
    
    func has(column: Int, row: Int) -> Bool {
        column + row * column < content.count
    }
    
    func item(column: Int, row: Int) -> Document {
        content[column + row * column]
    }
    
    func columns(targetCount: Int) -> Int {
        targetCount >= content.count ? content.count : targetCount
    }
    
    func rows(columns: Int) -> Int {
        Int((Double(content.count) / Double(columns)).rounded(.up))
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(content)
    }
    
    subscript(col: Int, row: Int) -> Document {
        item(column: col, row: row)
    }
    
    static func == (lhs: DocumentGroup, rhs: DocumentGroup) -> Bool {
        return lhs.id == rhs.id
    }
}

struct DocumentListView_Previews: PreviewProvider {
    
    @State static var documents: [Document] = []
    
    static var previews: some View {
        DocumentListView(documents: $documents)
    }
}

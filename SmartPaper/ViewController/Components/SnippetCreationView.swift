//
//  SnippetCreationView.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 31.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import SwiftUI

struct SnippetCreationView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var appData: AppData
    
    @Binding var waiting: Bool
    
    @Binding var snippets: Document.TextFindingResult
    
    @State private var selectedSnippets = Set<Snippet>()
    
    @State private var displayedSnippets: DisplayedSnippet = .all
    
    @State private var showOnlyLinks: Bool = false
    
    private var shownSnippets: [Snippet] {
        let snippets: [Snippet]
        
        if displayedSnippets == .all {
            snippets = self.snippets.byLine
        } else {
            snippets = self.snippets.merged
        }
        
        return snippets.filter { $0.hasLinks || !self.showOnlyLinks }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 20) {
                    Picker(selection: self.$displayedSnippets, label: Text("Shown Snippets")) {
                        Text("All Lines")
                            .tag(DisplayedSnippet.all)
                        Text("Auto Merged")
                            .tag(DisplayedSnippet.merged)
                    }.pickerStyle(SegmentedPickerStyle())
                    Button(action: { self.showOnlyLinks.toggle() }) {
                        Image(systemName: self.showOnlyLinks ? "link.circle.fill" : "link.circle")
                    }
                }
                .font(.title)
                
                List(shownSnippets) { snippet in
                    self.row(for: snippet)
                        .padding()
                }
                .navigationBarItems(trailing: self.navigationBar())
                .navigationBarTitle("Scanner Result")
            }.padding(.horizontal)
        }
        .blur(radius: waiting ? 3 : 0)
        .overlay(waiting ? waitingScreen() : nil)
    }
    
    private func navigationBar() -> some View {
        HStack(spacing: 10) {
            mergeButton()
            keepButton()
        }
    }
    
    private func mergeButton() -> some View {
        Button(action: {
            guard self.selectedSnippets.count > 0 else {
                return
            }
            
            let merged = Snippet.merge(snippets: self.selectedSnippets)
            
            if self.displayedSnippets == .all {
                self.selectedSnippets.forEach {
                    self.snippets.byLine.remove($0)
                }
                self.selectedSnippets.removeAll()
                self.snippets.byLine += [merged]
            } else {
                self.selectedSnippets.forEach {
                    self.snippets.merged.remove($0)
                }
                self.selectedSnippets.removeAll()
                self.snippets.merged += [merged]
            }
        }) {
            Text("Merge")
        }
    }
    
    private func keepButton() -> some View {
        Button(action: {
            self.appData.snippets += self.selectedSnippets
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Keep")
        }
    }
    
    private func row(for snippet: Snippet) -> some View {
        HStack(spacing: 20) {
            Button(action: { self.toggle(snippet: snippet) }) {
                Circle()
                    .stroke(Color.gray)
                    .frame(width: 25, height: 25)
                    .overlay(Circle()
                        .foregroundColor(self.selectedSnippets.contains(snippet) ? Color.blue : Color.clear)
                    )
                    .overlay(self.selectedSnippets.contains(snippet) ?
                        Image(systemName: "checkmark").foregroundColor(.white) : nil)
            }
            
            HStack(alignment: .top) {
                Text(snippet.content)
                Spacer()
                Image(systemName: "link")
                    .foregroundColor(Color.green)
                    .frame(width: 20, height: 20)
                    .opacity(snippet.hasLinks ? 1 : 0)
            }
            .padding(.trailing, 5)
        }
    }
    
    private func toggle(snippet: Snippet) {
        if selectedSnippets.contains(snippet) {
            selectedSnippets.remove(snippet)
        } else {
            selectedSnippets.insert(snippet)
        }
    }
    
    private func waitingScreen() -> some View {
        VStack {
            ActivityIndicator()
            Text("Please wait...")
                .font(Font.subheadline)
        }
        .padding()
        .foregroundColor(Color(.label))
        .background(Color(.systemBackground))
        .cornerRadius(5)
        .shadow(color: .gray,
                radius: 10, x: 0, y: 0)
    }
}

private extension SnippetCreationView {
    
    enum DisplayedSnippet {
        case all, merged
    }
    
}

struct SnippetCreationView_Previews: PreviewProvider {
    
    @State private static var waiting: Bool = false
    
    @State private static var snippets = (byLine: [Snippet(content: "Here we go", date: Date())],
                                          merged: [Snippet(content: "Here we go", date: Date())])
    
    static var previews: some View {
        SnippetCreationView(waiting: $waiting, snippets: $snippets)
    }
}

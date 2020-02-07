//
//  SnippetListView.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 24.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import SwiftUI

struct SnippetListView: View {
    
    @State private var sortDirection: SortDirection = .descending
    
    @State private var filterCondition: String = ""
    
    @Binding var snippets: [Snippet]
    
    private var sortImage: Image {
        switch sortDirection {
        case .ascending:
            return Image(systemName: "arrow.up.circle")
        case .descending:
            return Image(systemName: "arrow.down.circle")
        }
    }
    
    private var sortedSnippets: [Snippet] {
        shownSnippets.sorted {
            switch sortDirection {
            case .ascending:
                return $0.date < $1.date
            case .descending:
                return $0.date > $1.date
            }
        }
    }
    
    private var shownSnippets: [Snippet] {
        snippets.filter {
            $0.content.lowercased().contains(filterCondition.lowercased()) || filterCondition.isEmpty
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                toolbar()
                List {
                    ForEach(sortedSnippets) { snippet in
                        NavigationLink(destination: SnippetView(snippet: self.createBinding(for: snippet))) {
                            self.row(of: snippet)
                        }
                    }.onDelete(perform: delete(indecies:))
                }
            }
            .navigationBarTitle("Snippets")
        }
    }
    
    private func row(of snippet: Snippet) -> some View {
        let formatter = DateFormatter()
        let date = { () -> String in
            formatter.dateStyle = .medium
            return formatter.string(from: snippet.date)
        }()
        
        return VStack(alignment: .leading, spacing: 5) {
            Text(snippet.title)
                .font(.headline)
            Text(date)
                .font(.subheadline)
        }
        .padding()
    }
    
    private func toolbar() -> some View {
        HStack(spacing: 10) {
            searchField()
            Spacer()
            filterButton()
        }
        .padding()
    }
    
    private func searchField() -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Find Snippet", text: $filterCondition, onEditingChanged: {_ in }, onCommit: {})
                .foregroundColor(.primary)
                .disableAutocorrection(true)
            Button(action: clearFilterCondition) {
                Image(systemName: "xmark.circle")
            }
            .disabled(filterCondition.isEmpty)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private func filterButton() -> some View {
        Button(action: toggleSortDirection) {
            sortImage
                .font(.title)
        }
    }
    
    private func toggleSortDirection() {
        sortDirection = sortDirection == .ascending ? .descending : .ascending
    }
    
    private func clearFilterCondition() {
        filterCondition = ""
        UIApplication.shared.endEditing(false)
    }
    
    private func createBinding(for snippet: Snippet) -> Binding<Snippet> {
        let index = snippets.firstIndex { $0.id == snippet.id }
        return $snippets[index!]
    }
    
    private func delete(indecies: IndexSet) {
        let sorted = sortedSnippets
        
        indecies.forEach { index in
            snippets.remove(sorted[index])
        }
    }
}

private extension SnippetListView {
    
    enum SortDirection {
        case ascending
        case descending
    }
    
}

struct SnippetListView_Previews: PreviewProvider {
    @State static var snippets: [Snippet] = []
    
    static var previews: some View {
        SnippetListView(snippets: $snippets)
    }
}

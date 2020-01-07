//
//  SnippetView.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 24.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import SwiftUI

struct SnippetView: View {
    
    @State private var fontSize: Int = 18
    
    @Binding var snippet: Snippet
    
    private var dateDescription: String {
        let formatter = DateFormatter()
        return { () -> String in
            formatter.dateStyle = .long
            return formatter.string(from: snippet.date)
        }()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            HStack(spacing: 20) {
                Text("From:")
                Text(dateDescription)
            }
            ZStack {
                MultilineTextField(value: $snippet.content, fontSize: $fontSize)
                    .padding(10)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                VStack {
                    Spacer()
                    ScrollView(.vertical, showsIndicators: true) {
                        ForEach(snippet.links, id: \.self) { link in
                            Button(action: { self.open(link: link) }) {
                                HStack {
                                    Image(systemName: "link")
                                        .font(.subheadline)
                                    Text(link)
                                        .fontWeight(.semibold)
                                        .font(.subheadline)
                                }
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                            }
                        }
                    }
                    .frame(maxHeight: 130)
                }
                .padding()
            }
        }
        .padding()
        .navigationBarTitle(Text(""), displayMode: .inline)
        .onTapGesture {
            UIApplication.shared.endEditing(true)
        }
    }
    
    private func open(link: String) {
        guard let url = URL(string: link) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:])
    }
}

struct SnippetView_Previews: PreviewProvider {
    @State static var snippet = Snippet(content: "Moin", date: Date())
    
    static var previews: some View {
        SnippetView(snippet: $snippet)
    }
}

//
//  Snippet.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 25.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import Foundation

struct Snippet: Identifiable, Hashable, Codable {
    
    var content: String
    
    let id: UUID
    
    let date: Date
    
    var title: String {
        content.count > 20 ? "\(String(content.prefix(20)))..." : content.isEmpty ? "No Title" : content
    }
    
    var links: [String] {
        extractLinks()
            .map { $0.lowercased() }
            .map { addProtocol(to: $0) }
    }
    
    var hasLinks: Bool {
        links.count > 0
    }
    
    init(content: String, date: Date, id: UUID = UUID()) {
        self.content = content
        self.id = id
        self.date = date
    }
    
    private func addProtocol(to link: String) -> String {
        if link.starts(with: "https://") || link.starts(with: "http://") {
            return link
        }
        
        return "https://\(link)"
    }
    
    private func extractLinks() -> [String] {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))
            
            return matches.compactMap { match in
                guard let range = Range(match.range, in: content) else {
                    return nil
                }
                return String(content[range])
            }
        } catch {
            return []
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(content)
    }
    
    static func merge<T>(snippets: T) -> Snippet where T: Collection, T.Element == Snippet {
        guard snippets.count > 0 else {
            return Snippet(content: "", date: Date())
        }
        
        let content = snippets.sorted { $0.date < $1.date }.map { $0.content.trimmed }.joined()
        return Snippet(content: content, date: Date())
    }
    
    static func == (lhs: Snippet, rhs: Snippet) -> Bool {
        return lhs.id == rhs.id
    }
    
}

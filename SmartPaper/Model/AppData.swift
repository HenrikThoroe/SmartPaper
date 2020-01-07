//
//  DocumentStore.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 26.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import UIKit

class AppData: ObservableObject {
    
    @Published var documents: [Document]
    
    @Published var snippets: [Snippet]
    
    @Published var automaticallySaveScans: Bool
    
    static let empty = AppData(documents: [], snippets: [], automaticallySaveScans: true)
    
    private static let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    private static var documentsDirectory: URL {
        storeURL.appendingPathComponent("UserDocuments", isDirectory: true)
    }
    
    private static var snippetsDirectory: URL {
        storeURL.appendingPathComponent("Snippets", isDirectory: true)
    }
    
    init(documents: [Document], snippets: [Snippet], automaticallySaveScans: Bool) {
        self.documents = documents
        self.snippets = snippets
        self.automaticallySaveScans = automaticallySaveScans
    }
    
    func persist() throws {
        UserDefaults.standard.set(automaticallySaveScans, forKey: "automaticallySaveScans")
        
        if !FileManager.default.fileExists(atPath: AppData.documentsDirectory.absoluteURL.path) {
            try FileManager.default.createDirectory(at: AppData.documentsDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        if !FileManager.default.fileExists(atPath: AppData.snippetsDirectory.absoluteURL.path) {
            try FileManager.default.createDirectory(at: AppData.snippetsDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        try documents.forEach {
            let coder = PropertyListEncoder()
            coder.outputFormat = .binary
            let data = try coder.encode($0)
            let url = AppData.documentsDirectory.appendingPathComponent("\($0.id.uuidString).doc")
            try data.write(to: url.absoluteURL, options: .atomic)
        }
        
        try snippets.forEach {
            let coder = PropertyListEncoder()
            coder.outputFormat = .xml
            let data = try coder.encode($0)
            let url = AppData.snippetsDirectory.appendingPathComponent("\($0.id.uuidString).snippet")
            try data.write(to: url.absoluteURL, options: .atomic)
        }
        
        let documentIDs = documents.filter { !$0.shouldBeRemoved }.map { $0.id.uuidString }
        try AppData.documentFiles().forEach {
            if !documentIDs.contains($0.lastPathComponent.without(".doc")) {
                try FileManager.default.removeItem(at: $0)
            }
        }
        
        let snippetIDs = snippets.map { $0.id.uuidString }
        try AppData.snippetFiles().forEach {
            if !snippetIDs.contains($0.lastPathComponent.without(".snippet")) {
                try FileManager.default.removeItem(at: $0)
            }
        }
    }
    
    private static func documentFiles() throws -> [URL] {
        try FileManager.default.contentsOfDirectory(at: documentsDirectory,
                                                    includingPropertiesForKeys: nil,
                                                    options: .skipsHiddenFiles)
            .filter {
                $0.pathExtension.lowercased() == "doc"
            }
    }
    
    private static func snippetFiles() throws -> [URL] {
        try FileManager.default.contentsOfDirectory(at: snippetsDirectory,
                                                    includingPropertiesForKeys: nil,
                                                    options: .skipsHiddenFiles)
            .filter {
                $0.pathExtension.lowercased() == "snippet"
            }
    }
    
    static func load() throws -> AppData {
        let automaticallySaveScans = UserDefaults.standard.value(forKey: "automaticallySaveScans") as? Bool ?? true
        let docFiles = try FileManager.default.contentsOfDirectory(at: documentsDirectory,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: .skipsHiddenFiles)
        let snippetFiles = try FileManager.default.contentsOfDirectory(at: snippetsDirectory,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
        
        let documents = try docFiles.compactMap { file -> Document? in
            guard file.pathExtension.lowercased() == "doc", let data = try? Data(contentsOf: file) else {
                return nil
            }
            
            return try PropertyListDecoder().decode(Document.self, from: data)
        }
        
        let snippets = try snippetFiles.compactMap { file -> Snippet? in
            guard file.pathExtension.lowercased() == "snippet", let data = try? Data(contentsOf: file) else {
                return nil
            }
            
            return try PropertyListDecoder().decode(Snippet.self, from: data)
        }
        
        return AppData(documents: documents, snippets: snippets, automaticallySaveScans: automaticallySaveScans)
    }
    
}

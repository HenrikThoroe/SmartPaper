//
//  String.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 31.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import Foundation

extension String {
    
    var fullRange: Range<Index> {
        startIndex..<endIndex
    }
    
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func without(_ pattern: String) -> String {
        var buffer = self
        
        while let range = buffer.range(of: pattern) {
            buffer.removeSubrange(range)
        }
        
        return buffer
    }
    
}

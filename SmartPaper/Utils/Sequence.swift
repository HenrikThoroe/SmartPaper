//
//  Sequence.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 27.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import Foundation

extension Sequence {
    
    func group(by condition: (Element, Element) -> Bool) -> [[Element]] {
        var groups: [[Element]] = [[]]
        
        for item in self {
            var inGroup = false
            
            for groupIndex in 0..<groups.count {
                for groupItemIndex in 0..<groups[groupIndex].count {
                    if condition(groups[groupIndex][groupItemIndex], item) {
                        groups[groupIndex] += [item]
                        inGroup = true
                        break
                    }
                }
            }
            
            if !inGroup {
                groups += [[item]]
            }
        }
        
        return groups.filter {
            $0.count > 0
        }
    }
    
}

extension Sequence where Element: Equatable {
    
    func group() -> [[Element]] {
        group(by: ==)
    }
    
}

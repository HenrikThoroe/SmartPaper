//
//  Array.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 27.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import Foundation

extension Array {
    
    nonmutating func subArray(of indecies: Int...) -> Self {
        return indecies.map {
            self[$0]
        }
    }
    
    func removing(atOffsets offsets: IndexSet) -> Self {
        var copy = self
        copy.remove(atOffsets: offsets)
        return copy
    }
    
}

extension Array where Element: Equatable {
    
    mutating func remove(_ item: Element) {
        removeAll {
            $0 == item
        }
    }
    
}

//
//  CGRect.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 03.01.20.
//  Copyright © 2020 Henrik Thoroe. All rights reserved.
//

import CoreGraphics

extension CGRect {
    
    init?(points: (CGPoint, CGPoint, CGPoint, CGPoint)) {
        let array = [points.0, points.1, points.2, points.3]
        let grouped = array.group { $0.y == $1.y }
        
        guard grouped.count == 2, grouped[0].count == 2, grouped[1].count == 2 else {
            return nil
        }
        
        let width = (grouped[0][0].x - grouped[0][1].x).magnitude
        let height = (grouped[0][0].y - grouped[1][0].y).magnitude
        let origin = array.min { $0.x < $1.x && $0.y < $1.y }!
        
        self = CGRect(x: origin.x, y: origin.y, width: width, height: height)
    }
    
    func overlapsHorizontally(with otherRect: CGRect) -> Bool {
        maxX > otherRect.minX || (minX < otherRect.maxX && maxX > otherRect.minX)
    }
    
    static func + (lhs: CGRect, rhs: CGRect) -> CGRect {
        let minY = min(lhs.minY, rhs.minY)
        let maxY = max(lhs.maxY, rhs.maxY)
        let minX = min(lhs.minX, rhs.minX)
        let maxX = max(lhs.maxX, rhs.maxX)
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
}

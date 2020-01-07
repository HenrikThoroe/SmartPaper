//
//  CGPoint.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 01.01.20.
//  Copyright © 2020 Henrik Thoroe. All rights reserved.
//

import UIKit

extension CGPoint {
    
    func scalled(width: CGFloat, height: CGFloat) -> CGPoint {
        CGPoint(x: x * width, y: y * height)
    }
    
    func fliped(with size: CGSize) -> CGPoint {
        CGPoint(x: x, y: size.height - y)
    }
    
}

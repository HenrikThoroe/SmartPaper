//
//  Date.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 27.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import Foundation

extension Date {
    
    var daysSince1970: Int {
        Int(timeIntervalSince1970 / 60 / 60 / 24)
    }
    
    func localizedDate(using style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
    
}

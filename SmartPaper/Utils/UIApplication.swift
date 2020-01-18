//
//  UIApplication.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 26.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import SwiftUI

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}

//
//  with.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 29.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import Foundation

func with<T>(_ object: T, do action: (T) -> Void) {
    action(object)
}

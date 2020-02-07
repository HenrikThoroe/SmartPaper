//
//  ShareSheet.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 30.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import SwiftUI

struct ShareSheet<T>: UIViewControllerRepresentable {
    
    let sharedItems: [T]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
    
}

struct ShareSheet_Previews: PreviewProvider {
    static var previews: some View {
        ShareSheet(sharedItems: ["Hello, World"])
    }
}

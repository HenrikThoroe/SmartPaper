//
//  MultilineTextField.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 26.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import SwiftUI
import UIKit

struct MultilineTextField: UIViewRepresentable {
    
    @Binding var value: String
    
    @Binding var fontSize: Int
    
    private let view = UITextView()
    
    private let textViewDelegate = DelegateWrapper()
    
    private func update(text: String) {
        value = text
    }
    
    func makeUIView(context: Context) -> UITextView {
        textViewDelegate.onInput = update(text:)
        view.text = value
        view.font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: .regular)
        view.backgroundColor = .clear
        view.delegate = textViewDelegate
        
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        
    }
    
}

private class DelegateWrapper: NSObject, UITextViewDelegate {
    
    var onInput: (String) -> Void = { _ in }
    
    func textViewDidChange(_ textView: UITextView) {
        onInput(textView.text)
    }
}


//
//  TitleView.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 25.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import SwiftUI

struct TitleView<C: View>: View {
    
    let title: String
    
    let content: () -> C
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(Font.title)
                .bold()
                .padding()
                .padding(.top, 20)
            content()
        }
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView(title: "Test") {
            Text("MOIN")
        }
    }
}

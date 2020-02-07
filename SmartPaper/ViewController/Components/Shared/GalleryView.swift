//
//  GalleryView.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 25.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import SwiftUI

struct GalleryView<D: Hashable, C: View>: View {
    
    let data: [D]
    
    let content: (D) -> C
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 20) {
                ForEach(self.data, id: \.self) { item in
                    self.content(item)
                }
            }
        }
    }
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView(data: [UIImage(named: "Sample1")!]) { image in
            Image(uiImage: image)
        }
    }
}

//
//  GridView.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 27.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import SwiftUI

struct GridView<C: View>: View {
    
    let columns: Int
    
    let rows: Int
    
    let content: (Int, Int) -> C
    
    var body: some View {
        return VStack {
            ForEach(0..<self.rows) { row in
                HStack {
                    ForEach(0..<self.columns) { col in
                        self.content(row, col)
                    }
                }
            }
        }
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(columns: 4, rows: 4) {
            Text("\($0), \($1)")
        }
    }
}

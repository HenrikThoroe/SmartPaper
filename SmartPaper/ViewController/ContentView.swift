//
//  ContentView.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 24.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        TabView {
            ScannerView()
                .environmentObject(appData)
                .tabItem {
                    Image(systemName: "viewfinder")
                    Text("Scanner")
                }
            DocumentListView(documents: $appData.documents)
                .environmentObject(appData)
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Documents")
                }
            SnippetListView(snippets: $appData.snippets)
                .tabItem {
                    Image(systemName: "textformat.abc")
                    Text("Snippets")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  JetScript
//
//  Created by Kirlos Yousef on 17/12/2020.
//

import SwiftUI

class WindowSize {
    let minWidth : CGFloat = 600
    let minHeight : CGFloat = 400
}

struct MainView: View {
    @EnvironmentObject var script: Script
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                
                HStack{
                    EditorView()
                        .frame(minWidth: geometry.size.width / 2, maxWidth: .infinity,
                               minHeight: geometry.size.height, maxHeight: .infinity)
                        .environmentObject(script)
                    
                    OutputScrollView()
                        .frame(minWidth: geometry.size.width / 2, maxWidth: .infinity,
                               minHeight: geometry.size.height, maxHeight: .infinity)
                        .environmentObject(script)
                        .background(Color(.darkGray))
                }
            }
            .frame(minWidth: WindowSize().minWidth,
                   minHeight: WindowSize().minHeight)
            .background(Color(.controlBackgroundColor))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(Script())
    }
}

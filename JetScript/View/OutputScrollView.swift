//
//  OutputScrollView.swift
//  JetScript
//
//  Created by Kirlos Yousef on 18/12/2020.
//

import SwiftUI

/// The output pane to show the current live script output
struct OutputScrollView: View {
    @EnvironmentObject var script: Script
    
    var body: some View {
        ScrollView(){
            ScrollViewReader { scrollView in
                ForEach(script.output, id: \.self) { op in
                    Text(op)
                        .multilineTextAlignment(.leading)
                        .font(.custom("HelveticaNeue", size: 16))
                        .onAppear{
                            // scroll to the bottom on new output lines
                            scrollView.scrollTo(script.output[script.output.endIndex - 1])
                        }
                        .padding()
                }
            }
        }
    }
}

struct OutputScrollView_Previews: PreviewProvider {
    static var previews: some View {
        OutputScrollView()
            .environmentObject(Script())
    }
}

//
//  ScriptOutputView.swift
//  JetScript
//
//  Created by Kirlos Yousef on 18/12/2020.
//

import SwiftUI

/// The output pane to show the current live script output
struct ScriptOutputView: View {
    @EnvironmentObject var script: ScriptVM
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(){
                ScrollViewReader { scrollView in
                    VStack(alignment: .trailing) {
                        ForEach(script.output, id: \.self) { op in
                            Text(op)
                                .multilineTextAlignment(.leading)
                                .font(.custom("HelveticaNeue", size: 16))
                                .foregroundColor(Constants.labelColor)
                                .onAppear{
                                    // scroll to the bottom on new output lines
                                    scrollView.scrollTo(script.output[script.output.endIndex - 1])
                                }
                                .frame(maxWidth: .infinity,
                                       alignment: .leading)
                        }
                    }
                }
            }.padding()
        }
        .background(Constants.backgroundColor)
    }
}

struct ScriptOutputView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            ScriptOutputView()
                .environmentObject(ScriptVM())
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
            
            ScriptOutputView()
                .environmentObject(ScriptVM())
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light Mode")
        }
    }
}

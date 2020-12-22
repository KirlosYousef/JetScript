//
//  ProgressBarView.swift
//  JetScript
//
//  Created by Kirlos Yousef on 20/12/2020.
//

import SwiftUI

struct ProgressBarView: View {
    @EnvironmentObject var script: ScriptVM
    
    private func progress(width: CGFloat) -> CGFloat {
        let percentage =  Double(script.timeEstimate) /
            Double(script.allTime)
        return width - (width *  CGFloat(percentage))
    }
    
    var body: some View {
        if script.timeEstimate != 0 {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width,
                               height: geometry.size.height)
                        .opacity(0.2)
                        .foregroundColor(Color(.systemTeal))
                    
                    Rectangle()
                        .frame(width:
                                self.progress(width: geometry.size.width),
                               height: geometry.size.height)
                        .foregroundColor(Color(.systemBlue))
                        .animation(.linear)
                }
            }
        }
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProgressBarView()
                .frame(width: 400, height: 15)
                .environmentObject(ScriptVM())
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
            
            ProgressBarView()
                .frame(width: 400, height: 15)
                .environmentObject(ScriptVM())
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light Mode")
        }
    }
}

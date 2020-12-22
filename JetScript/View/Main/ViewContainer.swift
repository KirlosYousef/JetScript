//
//  ViewContainer.swift
//  JetScript
//
//  Created by Kirlos Yousef on 17/12/2020.
//

import SwiftUI

struct ViewContainer: View {
    @EnvironmentObject var script: ScriptVM
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                ZStack(alignment: .bottomLeading){
                    HStack{
                        ScriptInputView()
                            .frame(minWidth: geometry.size.width / 2, maxWidth: .infinity,
                                   minHeight: geometry.size.height, maxHeight: .infinity)
                            .environmentObject(script)
                        
                        Divider()
                        
                        ScriptOutputView()
                            .frame(minWidth: geometry.size.width / 2, maxWidth: .infinity,
                                   minHeight: geometry.size.height, maxHeight: .infinity)
                            .environmentObject(script)
                    }
                    
                    ProgressBarView()
                        .frame(width: geometry.size.width, height: 3)
                        .environmentObject(script)
                }
            }
            .frame(minWidth: Constants.minWidth,
                   minHeight: Constants.minHeight)
            .background(Constants.backgroundColor)
        }
    }
}

struct ViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        ViewContainer().environmentObject(ScriptVM())
    }
}

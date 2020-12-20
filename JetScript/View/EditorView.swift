//
//  EditorPaneView.swift
//  JetScript
//
//  Created by Kirlos Yousef on 18/12/2020.
//

import SwiftUI

/// The editor pane to write a script to execute
struct EditorView: View {
    @EnvironmentObject var script: Script
    @State private var inputText: String = ""
    @State private var pulseVModel = PulseViewModel()
    @State private var shouldAnimate: Bool = false
    @State private var numberOfTimes: Int = 1
    
    var body: some View {
        VStack(alignment: .trailing){
            TextEditor(text: $inputText)
                .font(.custom("HelveticaNeue", size: 16))
                .disableAutocorrection(true)
                .padding([.leading, .trailing, .top])
            
            HStack{
                PulsatingView(pulseViewModel: $pulseVModel, shouldAnimate: $shouldAnimate)
                
                Text(String(script.timeEstimate))
                    .padding()
                
                Spacer()
                
                Button(action: {
                    shouldAnimate = true
                    script.executeScript(inputText, times: numberOfTimes)
                    pulseVModel.colorInd = Int(script.exitCode)
                }) {
                    Text("Execute")
                }
                
                Stepper(value: $numberOfTimes, in: 1...100000) {
                    Text("\(numberOfTimes)")
                }
            }
            .padding([.leading, .trailing, .bottom])
        }
    }
}

struct EditorPaneView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
            .environmentObject(Script())
    }
}

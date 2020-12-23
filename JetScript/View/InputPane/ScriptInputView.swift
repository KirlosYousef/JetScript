//
//  ScriptInputView.swift
//  JetScript
//
//  Created by Kirlos Yousef on 18/12/2020.
//

import SwiftUI

/// The editor pane to write a script to execute
struct ScriptInputView: View {
    @EnvironmentObject var script: ScriptVM
    @State private var pulseVModel = PulseVM()
    @State private var shouldAnimate: Bool = false
    @State private var inputText: String = ""
    @State private var numberOfTimes: Int = 1
    
    var body: some View {
        VStack(alignment: .trailing){
            ScriptTextView(input: $inputText)
                .environmentObject(script)
                .padding([.leading, .trailing, .top])
            
            HStack{
                PulsatingView(pulseViewModel: $pulseVModel, shouldAnimate: $shouldAnimate)
                
                if (script.timeEstimate != 0){
                    Text("Seconds remaining: \(script.timeEstimate)")
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    shouldAnimate = true
                    script.executeScript(inputText, times: numberOfTimes)
                    pulseVModel.colorInd = Int(script.exitCode)
                }) {
                    Text("Execute")
                        .foregroundColor(Constants.labelColor)
                }
                
                Stepper(value: $numberOfTimes, in: 1...100000) {
                    Text("\(numberOfTimes)")
                        .foregroundColor(Constants.labelColor)
                }
            }
            .padding([.leading, .trailing, .bottom])
        }
        .background(Constants.backgroundColor)
    }
}

struct ScriptInputView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            ScriptInputView()
                .environmentObject(ScriptVM())
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
            
            ScriptInputView()
                .environmentObject(ScriptVM())
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light Mode")
        }
    }
}

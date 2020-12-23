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
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(alignment: .trailing){
            ScriptTextView(input: $inputText)
                .environmentObject(script)
                .padding([.leading, .trailing, .top])
            
            BottomLineView(inputText: $inputText)
                .environmentObject(script)
        }
        .background(Constants.backgroundColor)
    }
}

private struct BottomLineView: View {
    @EnvironmentObject var script: ScriptVM
    @Binding var inputText: String
    @State private var numberOfTimes: Int = 1
    @State private var pulseVModel = PulseVM()
    @State private var shouldAnimate: Bool = false
    
    var body: some View {
        VStack {
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
                
                Stepper(value: $numberOfTimes, in: 1...Int.max) {
                    Text("\(numberOfTimes)")
                        .foregroundColor(Constants.labelColor)
                }
            }
            .padding([.leading, .trailing, .bottom])
        }
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

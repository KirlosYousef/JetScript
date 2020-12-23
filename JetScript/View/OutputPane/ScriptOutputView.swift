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
                            Group{
                                if (op.contains("swift:") && op.contains("error") && (script.exitCode != 0)){
                                    outputErrorView(output: op)
                                        .environmentObject(script)
                                } else {
                                    outputTextView(output: op)
                                }
                            }.onAppear{
                                // scroll to the bottom on new output lines
                                scrollView.scrollTo(script.output[script.output.endIndex - 1])
                                script.errorLineIndex = -1
                            }
                        }
                    }
                }
            }
            .padding()
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

private struct outputTextView: View {
    @State var output: String
    
    var body: some View {
        Text(output)
            .multilineTextAlignment(.leading)
            .font(.custom("HelveticaNeue", size: 16))
            .foregroundColor(Constants.labelColor)
            .frame(maxWidth: .infinity,
                   alignment: .leading)
    }
}

private struct outputErrorView: View {
    @State var output: String
    @EnvironmentObject var script: ScriptVM
    @State var swiftBound: String.Index = String.Index(utf16Offset: 0, in: " ")
    @State var errorBound = String.Index(utf16Offset: 0, in: " ")
    
    var body: some View {
        HStack(alignment: .firstTextBaseline){
            if swiftBound < errorBound {
                Button(action: {
                    guard let line = Int(output.components(separatedBy: ":")[1]) else { return }
                    script.errorLineIndex = line
                }){
                    Text(
                        output[(swiftBound) ..< (errorBound)])
                        .underline()
                    
                }
                .buttonStyle(BorderlessButtonStyle())
                
                outputTextView(output: output[errorBound...].description)
            }
        }.onAppear{
            guard let swiftBound = output.range(of: "swift")?.lowerBound else { return }
            self.swiftBound = swiftBound
            guard let errorBound = output.range(of: "error")?.lowerBound else { return }
            self.errorBound = errorBound
        }
    }
}

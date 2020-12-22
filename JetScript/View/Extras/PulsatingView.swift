//
//  PulsatingView.swift
//  JetScript
//
//  Created by Kirlos Yousef on 18/12/2020.
//

import SwiftUI
import Combine

struct PulsatingView: View {
    @Binding var pulseViewModel: PulseVM
    @Binding var shouldAnimate: Bool
    
    func getColor() -> Color {
        switch pulseViewModel.colorInd {
        case 0:
            return Color(.systemGreen)
        case 1:
            return Color(.systemRed)
        default:
            return Color(.darkGray)
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle().fill(getColor().opacity(0.25)).frame(width: 40, height: 40).scaleEffect(shouldAnimate ? 1 : 0.1)
                Circle().fill(getColor().opacity(0.35)).frame(width: 30, height: 30).scaleEffect(shouldAnimate ? 1 : 0.1)
                Circle().fill(getColor().opacity(0.45)).frame(width: 20, height: 20).scaleEffect(shouldAnimate ? 1 : 0.1)
                Circle().fill(getColor()).frame(width: 10, height: 10)
            }
            .animation(shouldAnimate ? Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true) : .default)
            .onReceive(pulseViewModel.$colorInd) { _ in
                shouldAnimate = false
            }
        }
    }
}

private struct PulsatingViewPreview: View {
    @State private var model = PulseVM()
    @State var shouldAnimate = true
    
    var body: some View {
        VStack {
            PulsatingView(pulseViewModel: $model, shouldAnimate: $shouldAnimate)
        }
    }
}

struct PulseColorViewPreview_Previews: PreviewProvider {
    static var previews: some View {
        PulsatingViewPreview()
    }
}

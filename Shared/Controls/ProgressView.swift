//
//  ProgressView.swift
//  AssetCompressor (iOS)
//
//  Created by Ray Qu on 16/03/22.
//

import SwiftUI

struct ProgressView : View  {
    var progress: Double
    
    var body: some View {
        ZStack {
            Color.white
                .opacity(0.01)

            ZStack {
                ZStack {
                    Pulsation().padding()
                    Ring(progress: progress).padding()
                    Label(progress: progress)
                }
                .frame(width: 175, height: 175, alignment: .center)
                .padding()
            }
//            .background(Color.rgb(r: 59, g: 66, b: 80).opacity(0.9))
//            .cornerRadius(30)
        }
    
    }
}
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct Label : View {
    var progress: Double = 0
    var body: some View {
   
        ZStack {
            Text(
                String(format: "%.0f%%", progress * 100)
            )
            .font(.system(size: 32))
            .fontWeight(.heavy)
            .colorInvert()
        }
    }
}

struct Ring: View {
    var progress: Double = 0
    var colors: [Color] = [Color.outlineColor]
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.rgb(r: 59, g: 66, b: 80))
            
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .fill(AngularGradient(gradient: .init(colors: [Color.trackColor]), center: .center, startAngle: .degrees(270), endAngle: .init(degrees: 360)))

            Circle()
                .trim(from: 0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .fill(AngularGradient(gradient: .init(colors: colors), center: .center, startAngle: .degrees(270), endAngle: .init(degrees: 360)))
                .rotationEffect(Angle.init(degrees: 270))
                .animation(.spring(response: 2.0, dampingFraction: 1.0, blendDuration: 1.0), value: progress)
        }
        .padding(10)
    }
}

struct Pulsation: View {
    @State  private var pulsate = true
    var colors: [Color] = [Color.pulsatingColor]
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.pulsatingColor)
                .scaleEffect(pulsate ? 1.15 : 1.0)
                .animation(Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true))
                .onAppear {
                    self.pulsate.toggle()
                }
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.green
            ProgressView(progress: 0)
        }
    }
}

extension Color {
    static func rgb(r: Double, g: Double, b: Double) -> Color {
        return Color(red: r / 255, green: g / 255, blue: b / 255)
    }
    
    static let outlineColor = Color.rgb(r: 90, g: 217, b: 209)
    static let trackColor = Color.rgb(r: 52, g: 57, b: 70)
    static let pulsatingColor = Color.rgb(r: 73, g: 113, b: 148)
}

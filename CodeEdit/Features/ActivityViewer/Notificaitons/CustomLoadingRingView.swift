//
//  CustomLoadingRingView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 21.06.24.
//

import SwiftUI

struct CustomLoadingRingView: View {
    @State private var isAnimating = false
    @State private var previousValue: Bool = false
    var progress: Double?
    var currentTaskCount: Int

    let lineWidth: CGFloat = 2
    var body: some View {
        Circle()
            .stroke(style: StrokeStyle(lineWidth: lineWidth))
            .foregroundStyle(.tertiary)
            .overlay {
                if let progress = progress {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.accentColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                        .animation(.easeInOut, value: progress)
                } else {
                    Circle()
                        .trim(from: 0, to: 0.5)
                        .stroke(Color.accentColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                        .rotationEffect(
                            previousValue ?
                                .degrees(isAnimating ?  0 : -360)
                            : .degrees(isAnimating ? 360 : 0)
                        )
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                        .onAppear {
                            self.previousValue = isAnimating
                            self.isAnimating.toggle()
                        }
                }
            }
            .rotationEffect(.degrees(-90))
            .overlay {
                if currentTaskCount > 1 {
                    Text("\(currentTaskCount)")
                        .font(.caption)
                }
            }
    }
}

#Preview {
    Group {
        CustomLoadingRingView(currentTaskCount: 1)
            .frame(width: 22, height: 22)

        CustomLoadingRingView(progress: 0.65, currentTaskCount: 1)
            .frame(width: 22, height: 22)
    }
    .padding()
}

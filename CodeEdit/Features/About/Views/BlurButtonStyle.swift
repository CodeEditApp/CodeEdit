//
//  BlurButtonStyle.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 21/01/2023.
//

import SwiftUI

extension ButtonStyle where Self == BlurButtonStyle {
    static var blur: BlurButtonStyle { BlurButtonStyle() }
}

struct BlurButtonStyle: ButtonStyle {
    @Environment(\.controlSize)
    var controlSize

    var height: CGFloat {
        switch controlSize {
        case .large:
            return 28
        default:
            return 20
        }
    }

    @Environment(\.colorScheme)
    var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: height)
            .buttonStyle(.bordered)
            .background {
                switch colorScheme {
                case .dark:
                    Color
                        .gray
                        .opacity(0.001)
                        .overlay(.regularMaterial.blendMode(.plusLighter))
                        .overlay(Color.gray.opacity(0.30))
                        .overlay(Color.white.opacity(configuration.isPressed ? 0.20 : 0.00))
                case .light:
                    Color
                        .gray
                        .opacity(0.001)
                        .overlay(.regularMaterial.blendMode(.darken))
                        .overlay(Color.gray.opacity(0.15).blendMode(.plusDarker))
                @unknown default:
                    Color.black
                }
            }
            .cornerRadius(6)
    }
}

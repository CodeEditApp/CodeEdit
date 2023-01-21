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
    @Environment(\.controlSize) var controlSize

    var height: CGFloat {
        switch controlSize {
        case .large:
            return 30
        default:
            return 10
        }
    }

    @Environment(\.colorScheme) var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: height)
            .buttonStyle(.bordered)
            .background {
                switch colorScheme {
                case .dark:
                    Color
                        .gray
                        .opacity(0.1)
                        .overlay(.regularMaterial.blendMode(.plusLighter))
                        .overlay(Color.gray.opacity(0.35))
                case .light:
                    Color
                        .gray
                        .opacity(0.1)
                        .overlay(.regularMaterial.blendMode(.plusDarker))
                        .overlay(Color.gray.opacity(0.2).colorMultiply(.white))
                @unknown default:
                    Color.black
                }
            }
            .cornerRadius(7)
    }
}

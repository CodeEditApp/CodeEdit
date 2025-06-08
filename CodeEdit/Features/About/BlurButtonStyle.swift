//
//  BlurButtonStyle.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 21/01/2023.
//

import SwiftUI

extension ButtonStyle where Self == BlurButtonStyle {
    static var blur: BlurButtonStyle { BlurButtonStyle() }
    static var secondaryBlur: BlurButtonStyle { BlurButtonStyle(isSecondary: true) }
}

struct BlurButtonStyle: ButtonStyle {
    var isSecondary: Bool = false

    @Environment(\.controlSize)
    var controlSize

    @Environment(\.colorScheme)
    var colorScheme

    var height: CGFloat {
        switch controlSize {
        case .large:
            return 28
        default:
            return 20
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .frame(height: height)
            .background {
                switch colorScheme {
                case .dark:
                    ZStack {
                        Color.gray.opacity(0.001)
                        if isSecondary {
                            Rectangle()
                                .fill(.regularMaterial)
                        } else {
                            Rectangle()
                                .fill(.regularMaterial)
                                .blendMode(.plusLighter)
                        }
                        Color.gray.opacity(isSecondary ? 0.10 : 0.30)
                        Color.white.opacity(configuration.isPressed ? 0.10 : 0.00)
                    }
                case .light:
                    ZStack {
                        Color.gray.opacity(0.001)
                        Rectangle()
                            .fill(.regularMaterial)
                            .blendMode(.darken)
                        Color.gray.opacity(isSecondary ? 0.05 : 0.15)
                            .blendMode(.plusDarker)
                        Color.gray.opacity(configuration.isPressed ? 0.10 : 0.00)
                    }
                @unknown default:
                    Color.black
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: controlSize == .large ? 6 : 5))
    }
}

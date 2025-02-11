//
//  FeatureIcon.swift
//  CodeEdit
//
//  Created by Austin Condiff on 12/2/24.
//

import SwiftUI

struct FeatureIcon: View {
    private let symbol: Image
    private let color: Color
    private let size: CGFloat

    init(
        symbol: Image?,
        color: Color?,
        size: CGFloat?
    ) {
        self.symbol = symbol ?? Image(systemName: "exclamationmark.triangle")
        self.color = color ?? .white
        self.size = size ?? 20
    }

    var body: some View {
        Group {
            symbol
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .shadow(color: Color(NSColor.black).opacity(0.25), radius: size / 40, y: size / 40)
        .padding(size / 8)
        .foregroundColor(.white)
        .frame(width: size, height: size)
        .background(
            RoundedRectangle(
                cornerRadius: size / 4,
                style: .continuous
            )
            .fill(color.gradient)
            .shadow(color: Color(NSColor.black).opacity(0.25), radius: size / 40, y: size / 40)
        )
    }
}

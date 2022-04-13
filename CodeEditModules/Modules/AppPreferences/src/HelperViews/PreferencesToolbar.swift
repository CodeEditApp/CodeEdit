//
//  SwiftUIView.swift
//  
//
//  Created by Lukas Pistrol on 13.04.22.
//

import SwiftUI

struct PreferencesToolbar<T: View>: View {

    private var height: Double
    private var bgColor: Color
    private var content: () -> T

    init(
        height: Double = 27,
        bgColor: Color = Color(NSColor.controlBackgroundColor),
        @ViewBuilder content: @escaping () -> T
    ) {
        self.height = height
        self.bgColor = bgColor
        self.content = content
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(bgColor)
            HStack {
                content()
                    .padding(.horizontal, 8)
            }
        }
        .frame(height: height)
    }
}

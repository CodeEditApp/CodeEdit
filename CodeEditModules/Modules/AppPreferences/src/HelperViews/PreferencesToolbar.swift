//
//  SwiftUIView.swift
//  
//
//  Created by Lukas Pistrol on 13.04.22.
//

import SwiftUI
import CodeEditUI

struct PreferencesToolbar<T: View>: View {

    private var height: Double
    private var content: () -> T

    init(
        height: Double = 27,
        bgColor: Color = Color(NSColor.controlBackgroundColor),
        @ViewBuilder content: @escaping () -> T
    ) {
        self.height = height
        self.content = content
    }

    var body: some View {
        ZStack {
            EffectView(.contentBackground)
            HStack {
                content()
                    .padding(.horizontal, 8)
            }
        }
        .frame(height: height)
    }
}

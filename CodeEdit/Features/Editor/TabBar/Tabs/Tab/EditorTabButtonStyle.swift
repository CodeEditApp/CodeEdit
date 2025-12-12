//
//  EditorTabButtonStyle.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/4/22.
//

import SwiftUI

struct EditorTabButtonStyle: ButtonStyle {
    @Environment(\.colorScheme)
    var colorScheme

    @Binding private var isPressing: Bool

    init(isPressing: Binding<Bool>) {
        self._isPressing = isPressing
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, isPressed in
                self.isPressing = isPressed
            }
    }
}

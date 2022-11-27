//
//  TabBarItemButtonStyle.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/4/22.
//

import SwiftUI

struct TabBarItemButtonStyle: ButtonStyle {
    @Environment(\.colorScheme)
    var colorScheme

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @Binding
    private var isPressing: Bool

    init(isPressing: Binding<Bool>) {
        self._isPressing = isPressing
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed, perform: { isPressed in
                self.isPressing = isPressed
            })
    }
}

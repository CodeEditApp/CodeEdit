//
//  PressActionsModifier.swift
//  CodeEditModules/CodeEditUI
//
//  Created by Gabriel Theodoropoulos on 1/11/20.
//

import SwiftUI

struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: (() -> Void)?

    init(onPress: @escaping () -> Void, onRelease: (() -> Void)? = nil) {
        self.onPress = onPress
        self.onRelease = onRelease
    }

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in onPress() })
                    .onEnded({ _ in onRelease?() })
            )
    }
}

extension View {

    /// A custom view modifier for press actions with callbacks for `onPress` and `onRelease`.
    /// - Parameters:
    ///   - onPress: Action to perform once the view is pressed.
    ///   - onRelease: Action to perform once the view press is released.
    /// - Returns: some View
    func pressAction(onPress: @escaping (() -> Void), onRelease: (() -> Void)? = nil) -> some View {
        modifier(PressActions(onPress: onPress, onRelease: onRelease))
    }
}

//
//  PressActionsModifier.swift
//  CodeEditModules/CodeEditUI
//
//  Created by Gabriel Theodoropoulos on 1/11/20.
//

import SwiftUI

public struct PressActions: ViewModifier {
     var onPress: () -> Void
     var onRelease: () -> Void
     public init(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) {
         self.onPress = onPress
         self.onRelease = onRelease
     }
     public func body(content: Content) -> some View {
         content
             .simultaneousGesture(
                 DragGesture(minimumDistance: 0)
                     .onChanged({ _ in
                         onPress()
                     })
                     .onEnded({ _ in
                         onRelease()
                     })
             )
     }
}

public extension View {
    func pressAction(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: {
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
}

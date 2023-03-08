//
//  TabBarItemCloseButton.swift
//  CodeEdit
//
//  Created by Austin Condiff on 1/17/23.
//

import SwiftUI

struct TabBarItemCloseButton: View {
    var isActive: Bool
    var isHoveringTab: Bool
    var isDragging: Bool
    var closeAction: () -> Void

    @Binding
    var closeButtonGestureActive: Bool

    @Environment(\.colorScheme)
    var colorScheme

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    private var isPressingClose: Bool = false

    @State
    private var isHoveringClose: Bool = false

    let buttonSize: CGFloat = 16

    var body: some View {
        HStack {
            if prefs.preferences.general.tabBarStyle == .xcode {
                Image(systemName: "xmark")
                    .font(.system(size: 11.5, weight: .regular, design: .rounded))
                    .foregroundColor(
                        isActive
                        ? colorScheme == .dark ? .primary : Color(.controlAccentColor)
                        : .secondary
                    )
                    .padding(.top, -0.5)
            } else {
                Image(systemName: "xmark")
                    .font(.system(size: 9.5, weight: .medium, design: .rounded))
            }
        }
        .frame(width: buttonSize, height: buttonSize)
        .background(
            colorScheme == .dark
            ? Color(nsColor: .white)
                .opacity(isPressingClose ? 0.10 : isHoveringClose ? 0.05 : 0)
            : (
                prefs.preferences.general.tabBarStyle == .xcode
                ? Color(nsColor: isActive ? .controlAccentColor : .black)
                    .opacity(
                        isPressingClose
                        ? 0.25
                        : (isHoveringClose ? (isActive ? 0.10 : 0.06) : 0)
                    )
                : Color(nsColor: .black)
                    .opacity(isPressingClose ? 0.29 : (isHoveringClose ? 0.11 : 0))
            )
        )
        .foregroundColor(isPressingClose ? .primary : .secondary)
        .cornerRadius(2)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ _ in
                    isPressingClose = true
                    closeButtonGestureActive = true
                })
                .onEnded({ value in
                    if value.location.x > 0
                        && value.location.x < buttonSize
                        && value.location.y > 0
                        && value.location.y < buttonSize {
                        closeAction()
                    }
                    isPressingClose = false
                    closeButtonGestureActive = false
                })
        )
        .onHover { hover in
            isHoveringClose = hover
        }
        .accessibilityLabel(Text("Close"))
        // Only show when the mouse is hovering and there is no tab dragging.
        .opacity(isHoveringTab && !isDragging ? 1 : 0)
        .animation(.easeInOut(duration: 0.08), value: isHoveringTab)
        .padding(.leading, 4)
    }
}

struct TabBarItemCloseButton_Previews: PreviewProvider {
    @State static var closeButtonGestureActive = true

    static var previews: some View {
        TabBarItemCloseButton(
            isActive: false,
            isHoveringTab: false,
            isDragging: false,
            closeAction: { print("Close tab") },
            closeButtonGestureActive: $closeButtonGestureActive
        )
    }
}

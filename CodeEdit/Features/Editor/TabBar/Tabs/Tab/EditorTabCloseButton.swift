//
//  EditorTabCloseButton.swift
//  CodeEdit
//
//  Created by Austin Condiff on 1/17/23.
//

import SwiftUI

struct EditorTabCloseButton: View {
    var isActive: Bool
    var isHoveringTab: Bool
    var isDragging: Bool
    var closeAction: () -> Void
    @Binding var closeButtonGestureActive: Bool
    var isDocumentEdited: Bool = false

    @Environment(\.colorScheme)
    var colorScheme

    @AppSettings(\.general.tabBarStyle)
    var tabBarStyle

    @State private var isPressingClose: Bool = false
    @State private var isHoveringClose: Bool = false

    let buttonSize: CGFloat = 16

    var body: some View {
        HStack(alignment: .center) {
            if tabBarStyle == .xcode {
                Image(systemName: isDocumentEdited && !isHoveringTab ? "circlebadge.fill" : "xmark")
                    .font(
                        .system(
                            size: isDocumentEdited && !isHoveringTab ? 9.5 : 11.5,
                            weight: .regular,
                            design: .rounded
                        )
                    )
                    .foregroundColor(
                        isActive
                        ? colorScheme == .dark ? .primary : Color(.controlAccentColor)
                        : .secondary
                    )
            } else {
                Image(systemName: isDocumentEdited && !isHoveringTab ? "circlebadge.fill" : "xmark")
                    .font(.system(size: 9.5, weight: .medium, design: .rounded))
            }
        }
        .frame(width: buttonSize, height: buttonSize)
        .background(
            colorScheme == .dark
            ? Color(nsColor: .white)
                .opacity(isPressingClose ? 0.10 : isHoveringClose ? 0.05 : 0)
            : (
                tabBarStyle == .xcode
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
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ _ in
                    isPressingClose = true
                    closeButtonGestureActive = true
                })
                .onEnded({ value in
                    // If the final position of the mouse is within the bounds of the
                    // close button then close the tab
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
        .opacity((isHoveringTab || isDocumentEdited == true) && !isDragging ? 1 : 0)
        .animation(.easeInOut(duration: 0.08), value: isHoveringTab)
        .padding(.leading, 4)
    }
}

struct EditorTabCloseButton_Previews: PreviewProvider {
    @State static var closeButtonGestureActive = true

    static var previews: some View {
        EditorTabCloseButton(
            isActive: false,
            isHoveringTab: false,
            isDragging: false,
            closeAction: { print("Close tab") },
            closeButtonGestureActive: $closeButtonGestureActive
        )
    }
}

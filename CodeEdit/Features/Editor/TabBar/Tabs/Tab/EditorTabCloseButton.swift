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

    @State private var isPressingClose: Bool = false
    @Binding var isHoveringClose: Bool

    let buttonSize: CGFloat = 16

    var body: some View {
        HStack(alignment: .center) {
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
        }
        .frame(width: buttonSize, height: buttonSize)
        .background(backgroundColor)
        .foregroundColor(isPressingClose ? .primary : .secondary)
        .if(.tahoe) {
            $0.clipShape(Circle())
        } else: {
            $0.clipShape(RoundedRectangle(cornerRadius: 2))
        }
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
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(Text("Close"))
        // Only show when the mouse is hovering and there is no tab dragging.
        .opacity((isHoveringTab || isDocumentEdited == true) && !isDragging ? 1 : 0)
        .animation(.easeInOut(duration: 0.08), value: isHoveringTab)
        .padding(.leading, 4)
    }

    @ViewBuilder var backgroundColor: some View {
        if colorScheme == .dark {
            let opacity: Double = if isPressingClose {
                0.10
            } else if isHoveringClose {
                0.05
            } else {
                0
            }

            Color(nsColor: .white)
                .opacity(opacity)
        } else {
            let opacity: Double = if isPressingClose {
                0.25
            } else if isHoveringClose {
                if isActive {
                    0.10
                } else {
                    0.06
                }
            } else {
                0.0
            }

            Color(nsColor: isActive ? .controlAccentColor : .systemGray)
                .opacity(opacity)
        }
    }
}

@available(macOS 14.0, *)
#Preview {
    @Previewable @State var closeButtonGestureActive: Bool = false
    @Previewable @State var isHoveringClose: Bool = false

    return EditorTabCloseButton(
        isActive: false,
        isHoveringTab: false,
        isDragging: false,
        closeAction: { print("Close tab") },
        closeButtonGestureActive: $closeButtonGestureActive,
        isHoveringClose: $isHoveringClose
    )
}

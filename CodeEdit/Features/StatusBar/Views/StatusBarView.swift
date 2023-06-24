//
//  StatusBarView.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 19.03.22.
//

import SwiftUI

/// # StatusBarView
///
/// A View that lives on the bottom of the window and offers information
/// about compilation errors/warnings, git,  cursor position in text,
/// indentation width (in spaces), text encoding and linebreak
///
/// Additionally it offers a togglable/resizable drawer which can
/// host a terminal or additional debug information
///
struct StatusBarView: View {
    @Environment(\.controlActiveState)
    private var controlActive

    @EnvironmentObject private var model: DebugAreaViewModel

    static let height = 28.0

    @Environment(\.colorScheme)
    private var colorScheme

    var proxy: SplitViewProxy

    static let statusbarID = "statusbarID"

    /// The actual status bar
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
//            StatusBarBreakpointButton()
//            StatusBarDivider()
            Spacer()
            HStack(alignment: .center, spacing: 10) {
                StatusBarCursorLocationLabel()
            }
            StatusBarDivider()
            StatusBarToggleDrawerButton()
        }
        .padding(.horizontal, 10)
        .cursor(.resizeUpDown)
        .frame(height: Self.height)
        .background(.bar)
        .padding(.top, 1)
        .overlay(alignment: .top) {
            Divider()
                .overlay(Color(nsColor: colorScheme == .dark ? .black : .clear))
        }
        .gesture(dragGesture)
        .disabled(controlActive == .inactive)
    }

    /// A drag gesture to resize the drawer beneath the status bar
    private var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                proxy.setPosition(of: 0, position: value.location.y + Self.height / 2)
            }
    }
}

struct StatusBarDivider: View {
    var body: some View {
        Divider()
            .frame(maxHeight: 12)
//            .padding(.horizontal, 7)
    }
}

extension View {
    func cursor(_ cursor: NSCursor) -> some View {
        onHover {
            if $0 {
                cursor.push()
            } else {
                cursor.pop()
            }
        }
    }
}

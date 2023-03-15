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
/// About compilation errors/warnings, git,  cursor position in text,
/// Indentation width (in spaces), text encoding and linebreak
///
/// Additionally it offers a togglable/resizable drawer which can
/// Host a terminal or additional debug information
///
struct StatusBarView: View {
    @Environment(\.controlActiveState)
    private var controlActive

    @EnvironmentObject
    private var model: StatusBarViewModel

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    static let height = 29.0

    @Environment(\.colorScheme)
    private var colorScheme

    var proxy: SplitViewProxy

    @Binding
    var collapsed: Bool

    static let statusbarID = "statusbarID"

    /// The actual status bar
    var body: some View {
        VStack(spacing: 4) {
            Divider()
            HStack(spacing: 15) {
                HStack(spacing: 5) {
                    StatusBarBreakpointButton()
                    Divider()
                        .frame(maxHeight: 12)
                        .padding(.horizontal, 7)
                    SegmentedControl($model.selectedTab, options: StatusBarTabType.allOptions)
                        .opacity(collapsed ? 0 : 1)
                }
                Spacer()
                StatusBarCursorLocationLabel()
                StatusBarIndentSelector()
                StatusBarEncodingSelector()
                StatusBarLineEndSelector()
                StatusBarToggleDrawerButton(collapsed: $collapsed)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 3)
        }
        .cursor(.resizeUpDown)
        .frame(height: Self.height)
        .background(.bar)
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

//
//  StatusBarView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 19.03.22.
//

import SwiftUI
import CodeEditUI

/// # StatusBarView
///
/// A View that lives on the bottom of the window and offers information
/// about compilation errors/warnings, git,  cursor position in text,
/// indentation width (in spaces), text encoding and linebreak.
///
/// Also information about the file size and dimensions, if available.
///
/// Additionally it offers a togglable/resizable drawer which can
/// host a terminal or additional debug information
///
struct StatusBarView: View {
    @Environment(\.controlActiveState)
    private var controlActive

    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    /// Read from `LayoutMetrics` rather than declared locally: `CEEditor` insets its content by the
    /// same value in three places, and a second source of truth would desync them on macOS 26.
    static var height: CGFloat { LayoutMetrics.statusBarHeight }

    private var trailingPadding: CGFloat {
        if #available(macOS 26, *) {
            8
        } else {
            0
        }
    }

    @Environment(\.colorScheme)
    private var colorScheme

    var proxy: SplitViewProxy

    static let statusbarID = "statusbarID"

    /// The actual status bar
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ForEach(utilityAreaViewModel.tabItems, id: \.id) { tab in
                let isSelected = utilityAreaViewModel.selectedTabID == tab.id
                let tint: NSColor = isSelected ? .controlAccentColor : .secondaryLabelColor
                Button {
                    utilityAreaViewModel.selectedTabID = tab.id
                } label: {
                    Image(systemName: tab.systemImage)
                        .foregroundStyle(Color(nsColor: tint))
                }
                .buttonStyle(.icon)
                .help(tab.title)
            }
//            StatusBarBreakpointButton()
//            StatusBarDivider()
            Spacer()
            StatusBarFileInfoView()
            StatusBarCursorPositionLabel()
            StatusBarDivider()
            StatusBarToggleUtilityAreaButton()
        }
        .padding(.horizontal, 10)
        .padding(.trailing, trailingPadding)
        .cursor(.resizeUpDown)
        .frame(height: Self.height - 1.0)
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

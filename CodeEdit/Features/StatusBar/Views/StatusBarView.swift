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

    @EnvironmentObject
    private var model: StatusBarViewModel

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    static let height = 29.0

    @Environment(\.colorScheme)
    private var colorScheme

    var proxy: SplitViewProxy

    @Binding var collapsed: Bool

    static let statusbarID = "statusbarID"

    /// The actual status bar
    var body: some View {
        VStack {
            Divider()
//            Spacer()
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
//            Spacer()
            Divider()
        }
//        .overlay(alignment: .top) {
//            PanelDivider()
//        }
//        .overlay(alignment: .bottom) {
//            if model.isExpanded {
//                PanelDivider()
//            }
//        }
        .background(.bar)
        .gesture(dragGesture)
        .onHover { isHovering($0, isDragging: model.isDragging, cursor: .resizeUpDown) }
        .disabled(controlActive == .inactive)
        .frame(height: Self.height)

    }

    /// A drag gesture to resize the drawer beneath the status bar
    private var dragGesture: some Gesture {

        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                model.isDragging = true
                proxy.setPosition(of: 0, position: value.location.y + Self.height / 2)
//                var newHeight = max(0, min(model.currentHeight - value.translation.height, 500))
//                if newHeight-0.5 > model.currentHeight || newHeight+0.5 < model.currentHeight {
//                    if newHeight < model.minHeight { // simulate the snapping/resistance after reaching minimal height
//                        if newHeight > model.minHeight / 2 {
//                            newHeight = model.minHeight
//                        } else {
//                            newHeight = 0
//                        }
//                    }
//                    model.currentHeight = newHeight
//                }
//                model.isExpanded = model.currentHeight < 1 ? false : true
            }
            .onEnded { _ in
                model.isDragging = false
            }
    }
}

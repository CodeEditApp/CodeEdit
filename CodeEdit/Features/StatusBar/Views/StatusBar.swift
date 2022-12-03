//
//  StatusBar.swift
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

    @ObservedObject
    private var model: StatusBarViewModel

    /// Initialize with model
    /// - Parameter model: The statusbar model
    init(model: StatusBarViewModel) {
        self.model = model
    }

    var body: some View {
        VStack(spacing: 0) {
            bar
            if model.isExpanded {
                StatusBarDrawer(model: model)
                    .transition(.move(edge: .bottom))
            }
        }
        .disabled(controlActive == .inactive)
        // removes weird light gray bar above when in light mode
        .padding(.top, -8) // (comment out to make it look normal in preview)
    }

    /// The actual status bar
    private var bar: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.bar)
            HStack(spacing: 15) {
                HStack(spacing: 5) {
                    StatusBarBreakpointButton(model: model)
                    Divider()
                        .frame(maxHeight: 12)
                        .padding(.horizontal, 7)
                    SegmentedControl($model.selectedTab, options: StatusBarTabType.allOptions)
                        .opacity(model.isExpanded ? 1 : 0)
                }
                Spacer()
                StatusBarCursorLocationLabel(model: model)
                StatusBarIndentSelector(model: model)
                StatusBarEncodingSelector(model: model)
                StatusBarLineEndSelector(model: model)
                StatusBarToggleDrawerButton(model: model)
            }
            .padding(.horizontal, 10)
        }
        .overlay(alignment: .top) {
            PanelDivider()
        }
        .overlay(alignment: .bottom) {
            if model.isExpanded {
                PanelDivider()
            }
        }
        .frame(height: 29)
        .gesture(dragGesture)
        .onHover { isHovering($0, isDragging: model.isDragging, cursor: .resizeUpDown) }
    }

    /// A drag gesture to resize the drawer beneath the status bar
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                model.isDragging = true
                var newHeight = max(0, min(model.currentHeight - value.translation.height, 500))
                if newHeight-0.5 > model.currentHeight || newHeight+0.5 < model.currentHeight {
                    if newHeight < model.minHeight { // simulate the snapping/resistance after reaching minimal height
                        if newHeight > model.minHeight / 2 {
                            newHeight = model.minHeight
                        } else {
                            newHeight = 0
                        }
                    }
                    model.currentHeight = newHeight
                }
                model.isExpanded = model.currentHeight < 1 ? false : true
            }
            .onEnded { _ in
                model.isDragging = false
            }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .bottom) {
            Color.white
            StatusBarView(model: StatusBarViewModel(workspaceURL: URL(fileURLWithPath: "")))
                .previewLayout(.fixed(width: 1.336, height: 500.0))
                .preferredColorScheme(.light)
        }
    }
}

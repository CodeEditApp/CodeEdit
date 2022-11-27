//
//  SegmentedControl.swift
//  CodeEditModules/CodeEditUI
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

/// A view that creates a segmented control from an array of text labels.
struct SegmentedControl: View {
    private var options: [String]
    private var prominent: Bool

    @Binding
    private var preselectedIndex: Int

    /// A view that creates a segmented control from an array of text labels.
    /// - Parameters:
    ///   - selection: The index of the current selected item.
    ///   - options: the options to display as an array of strings.
    ///   - prominent: A Bool indicating whether to use a prominent appearance instead
    ///   of the muted selection color. Defaults to `false`.
    init(
        _ selection: Binding<Int>,
        options: [String],
        prominent: Bool = false
    ) {
        self._preselectedIndex = selection
        self.options = options
        self.prominent = prominent
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options.indices, id: \.self) { index in
                SegmentedControlItem(
                    label: options[index],
                    active: preselectedIndex == index,
                    action: {
                        preselectedIndex = index
                    },
                    prominent: prominent
                )

            }
        }
        .frame(height: 20)
    }
}

struct SegmentedControlItem: View {
    private let color: Color = Color(nsColor: .selectedControlColor)
    let label: String
    let active: Bool
    let action: () -> Void
    let prominent: Bool

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    @State
    var isHovering: Bool = false

    @State
    var isPressing: Bool = false

    var body: some View {
        Text(label)
            .font(.subheadline)
            .foregroundColor(textColor)
            .opacity(textOpacity)
            .frame(height: 20)
            .padding(.horizontal, 7.5)
            .background(
                background
            )
            .cornerRadius(5)
            .onTapGesture {
                action()
            }
            .onHover { hover in
                isHovering = hover
            }
            .pressAction {
                isPressing = true
            } onRelease: {
                isPressing = false
            }

    }

    private var textColor: Color {
        if prominent {
            return active
            ? .white
            : .primary
        } else {
            return active
            ? colorScheme == .dark ? .white : .accentColor
            : .primary
        }
    }

    private var textOpacity: Double {
        if prominent {
            return activeState != .inactive ? 1 : active ? 1 : 0.3
        } else {
            return activeState != .inactive ? 1 : active ? 0.5 : 0.3
        }
    }

    @ViewBuilder
    private var background: some View {
        if prominent {
            if active {
                Color.accentColor.opacity(activeState != .inactive ? 1 : 0.5)
            } else {
                Color(nsColor: colorScheme == .dark ? .white : .black)
                .opacity(isPressing ? 0.10 : isHovering ? 0.05 : 0)
            }
        } else {
            if active {
                color.opacity(isPressing ? 1 : activeState != .inactive ? 0.75 : 0.5)
            } else {
                Color(nsColor: colorScheme == .dark ? .white : .black)
                .opacity(isPressing ? 0.10 : isHovering ? 0.05 : 0)
            }
        }
    }
}

struct SegmentedControl_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedControl(.constant(0), options: ["Tab 1", "Tab 2"], prominent: true)
            .padding()

        SegmentedControl(.constant(0), options: ["Tab 1", "Tab 2"])
            .padding()
    }
}

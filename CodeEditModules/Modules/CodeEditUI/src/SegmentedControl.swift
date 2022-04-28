//
//  SegmentedControl.swift
//  
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

/// A view that creates a segmented control from an array of text labels.
public struct SegmentedControl: View {
    /// A view that creates a segmented control from an array of text labels.
    /// - Parameters:
    ///   - selection: The index of the current selected item.
    ///   - options: the options to display as an array of strings.
    ///   - color: The color of the selected item. Defaults to `NSColor.selectedControlColor`
    public init(
        _ selection: Binding<Int>,
        options: [String],
        color: Color = Color(nsColor: .selectedControlColor)
    ) {
        self._preselectedIndex = selection
        self.options = options
        self.color = color
    }

    @Binding
    private var preselectedIndex: Int

    private var options: [String]

    private let color: Color

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(options.indices, id: \.self) { index in
                SegmentedControlItem(
                    label: options[index],
                    active: preselectedIndex == index,
                    action: {
                        preselectedIndex = index
                    },
                    color: color
                )

            }
        }
        .frame(height: 20)
    }
}

struct SegmentedControlItem: View {
    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    @State
    var isHovering: Bool = false

    @State
    var isPressing: Bool = false

    let label: String

    let active: Bool

    let action: () -> Void

    let color: Color

    public var body: some View {
        Text(label)
            .font(.subheadline)
            .foregroundColor(active
                             ? colorScheme == .dark ? .white : .accentColor
                             : .primary)
            .opacity(activeState != .inactive ? 1 : active ? 0.5 : 0.3)
            .frame(height: 20)
            .padding(.horizontal, 7.5)
            .background(
                active
                ? color.opacity(isPressing ? 1 : activeState != .inactive ? 0.75 : 0.5)
                : Color(nsColor: colorScheme == .dark ? .white : .black)
                    .opacity(isPressing ? 0.10 : isHovering ? 0.05 : 0)
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
}

struct SegmentedControl_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedControl(.constant(0), options: ["Tab 1", "Tab 2"])
            .padding()
    }
}

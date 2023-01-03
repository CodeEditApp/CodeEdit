//
//  SegmentedControl.swift
//  CodeEditModules/CodeEditUI
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI


extension ButtonStyle where Self == XcodeButtonStyle {
    static func xcodeButton(isActive: Bool, prominent: Bool, isHovering: Bool, namespace: Namespace.ID = Namespace().wrappedValue) -> XcodeButtonStyle {
        XcodeButtonStyle(isActive: isActive, prominent: prominent, isHovering: isHovering, namespace: namespace)
    }
}

struct XcodeButtonStyle: ButtonStyle {
    var isActive: Bool
    var prominent: Bool
    var isHovering: Bool
    var namespace: Namespace.ID

    @Environment(\.controlSize) var controlSize

    @Environment(\.colorScheme) var colorScheme

    @Environment(\.controlActiveState) private var activeState

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, controlSizePadding.horizontal)
            .padding(.vertical, controlSizePadding.vertical)
            .font(fontSize)
            .opacity(textOpacity)
            .background {
                if isActive {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.accentColor)
                        .opacity(configuration.isPressed ? (prominent ? 0.75 : 0.5) : (prominent ? 1 : 0.75))
                        .matchedGeometryEffect(id: "bg", in: namespace)
                } else if isHovering {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.gray)
                        .opacity(0.2)
                        .transition(.opacity)
                        .animation(.easeInOut, value: isHovering)
                }
            }
            .opacity(activeState == .inactive ? 0.6 : 1)
    }

    var fontSize: Font {
        switch controlSize {
        case .mini:
            return .footnote
        case .small, .regular:
            return .subheadline
        default:
            return .callout
        }
    }

    var controlSizePadding: (vertical: CGFloat, horizontal: CGFloat) {
        switch controlSize {
        case .mini:
            return (1, 2)
        case .small:
            return (2, 4)
        case .regular:
            return (4, 8)
        case .large:
            return (6, 12)
        @unknown default:
            return (4, 8)
        }
    }

    private var textOpacity: Double {
        if prominent {
            return activeState != .inactive ? 1 : isActive ? 1 : 0.3
        } else {
            return activeState != .inactive ? 1 : isActive ? 0.5 : 0.3
        }
    }
}

/// A view that creates a segmented control from an array of text labels.
struct SegmentedControlImproved<T: Identifiable & CustomStringConvertible & Equatable>: View {

    @Binding
    private var selection: T

    private var options: [T]
    private var prominent: Bool

    @State var hoveringOver: T.ID?

    /// A view that creates a segmented control from an array of text labels.
    /// - Parameters:
    ///   - selection: The index of the current selected item.
    ///   - options: the options to display as an array of strings.
    ///   - prominent: A Bool indicating whether to use a prominent appearance instead
    ///   of the muted selection color. Defaults to `false`.
    init(selection: Binding<T>, options: [T], prominent: Bool) {
        self._selection = selection
        self.options = options
        self.prominent = prominent
    }

    @Namespace var namespace

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.id) { option in
                Button(option.description) {
                    hoveringOver = nil
                    selection = option
                }
                .buttonStyle(.xcodeButton(isActive: option == selection, prominent: prominent, isHovering: option.id == hoveringOver, namespace: namespace))
                .onHover { hover in
                    hoveringOver = hover ? option.id : nil
                }
                .animation(.interpolatingSpring(stiffness: 600, damping: 50), value: selection)
            }
        }
    }
}

/// A view that creates a segmented control from an array of text labels.
struct SegmentedControl: View {
    private var options: [String]
    private var prominent: Bool

    @Binding
    private var preselectedIndex: Int

    @Namespace var namespace

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

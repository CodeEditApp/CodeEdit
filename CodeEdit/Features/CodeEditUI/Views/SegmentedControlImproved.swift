//
//  SegmentedControlImproved.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 22/05/2023.
//

import SwiftUI

extension ButtonStyle where Self == XcodeButtonStyle {
    static func xcodeButton(
        isActive: Bool,
        prominent: Bool,
        isHovering: Bool,
        namespace: Namespace.ID = Namespace().wrappedValue
    ) -> XcodeButtonStyle {
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
            .foregroundColor(isActive ? .white : .primary)
            .opacity(textOpacity)
            .background {
                if isActive {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.accentColor)
                        .opacity(configuration.isPressed ? (prominent ? 0.75 : 0.5) : (prominent ? 1 : 0.75))
                        .matchedGeometryEffect(id: "xcodebuttonbackground", in: namespace)

                } else if isHovering {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.gray)
                        .opacity(0.2)
                        .transition(.opacity)
                        .animation(.easeInOut, value: isHovering)
                }
            }
            .opacity(activeState == .inactive ? 0.6 : 1)
            .animation(.interpolatingSpring(stiffness: 600, damping: 50), value: isActive)
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
            return (3, 8)
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

private struct MyTag: _ViewTraitKey {
    static var defaultValue: AnyHashable? = Optional<Int>.none
}

extension View {
    func segmentedTag<Value: Hashable>(_ value: Value) -> some View {
        _trait(MyTag.self, value)
    }
}

struct SegmentedControlV2<Selection: Hashable, Content: View>: View {
    @Binding var selection: Selection
    var prominent: Bool
    @ViewBuilder var content: Content

    @State private var hoveringOver: Selection?

    @Namespace var namespace

    var body: some View {
        content.variadic { children in
            HStack(spacing: 8) {
                ForEach(children, id: \.id) { option in
                    let tag: Selection? = option[MyTag.self].flatMap { $0 as? Selection }
                    Button {
                        hoveringOver = nil
                        if let tag {
                            selection = tag
                        }
                    } label: {
                        option
                    }
                    .buttonStyle(
                        .xcodeButton(
                            isActive: tag == selection,
                            prominent: prominent,
                            isHovering: tag == hoveringOver,
                            namespace: namespace
                        )
                    )
                    .onHover { hover in
                        hoveringOver = hover ? tag : nil
                    }
                    .animation(.interpolatingSpring(stiffness: 600, damping: 50), value: selection)
                }
            }
        }
    }
}

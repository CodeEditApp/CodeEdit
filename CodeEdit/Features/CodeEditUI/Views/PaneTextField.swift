//
//  PaneTextField.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/2/23.
//

import SwiftUI
import Combine

struct PaneTextField<LeadingAccessories: View, TrailingAccessories: View>: View {
    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.controlActiveState)
    private var controlActive

    @FocusState private var isFocused: Bool

    var label: String

    @Binding private var text: String

    let axis: Axis

    let leadingAccessories: LeadingAccessories?

    let trailingAccessories: TrailingAccessories?

    var clearable: Bool

    var onClear: (() -> Void)

    var hasValue: Bool

    init(
        _ label: String,
        text: Binding<String>,
        axis: Axis? = .horizontal,
        @ViewBuilder leadingAccessories: () -> LeadingAccessories? = { EmptyView() },
        @ViewBuilder trailingAccessories: () -> TrailingAccessories? = { EmptyView() },
        clearable: Bool? = false,
        onClear: (() -> Void)? = {},
        hasValue: Bool? = false
    ) {
        self.label = label
        _text = text
        self.axis = axis ?? .horizontal
        self.leadingAccessories = leadingAccessories()
        self.trailingAccessories = trailingAccessories()
        self.clearable = clearable ?? false
        self.onClear = onClear ?? {}
        self.hasValue = hasValue ?? false
    }

    @ViewBuilder
    public func selectionBackground(
        _ isFocused: Bool = false
    ) -> some View {
        if self.controlActive != .inactive || !text.isEmpty || hasValue {
            if isFocused || !text.isEmpty || hasValue {
                Color(.textBackgroundColor)
            } else {
                if colorScheme == .light {
                    Color.black.opacity(0.06)
                } else {
                    Color.white.opacity(0.24)
                }
            }
        } else {
            if colorScheme == .light {
                Color.clear
            } else {
                Color.white.opacity(0.14)
            }
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if let leading = leadingAccessories {
                leading
                    .frame(height: 20)
            }
            VStack {
                TextField(label, text: $text, axis: axis)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .controlSize(.small)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .foregroundStyle(.primary)
            }
            if clearable == true {
                Button {
                    self.text = ""
                    onClear()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.icon(font: .system(size: 11, weight: .semibold), size: CGSize(width: 20, height: 20)))
                .opacity(text.isEmpty ? 0 : 1)
                .disabled(text.isEmpty)
            }
            if let trailing = trailingAccessories {
                trailing
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .buttonStyle(.icon(font: .system(size: 11, weight: .semibold), size: CGSize(width: 28, height: 20)))
        .toggleStyle(.icon(font: .system(size: 11, weight: .semibold), size: CGSize(width: 28, height: 20)))
        .frame(minHeight: 22)
        .background(
            selectionBackground(isFocused)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .edgesIgnoringSafeArea(.all)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isFocused || !text.isEmpty || hasValue ? .tertiary : .quaternary, lineWidth: 1.25)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .disabled(true)
                .edgesIgnoringSafeArea(.all)
        )

        .onTapGesture {
            isFocused = true
        }
    }
}

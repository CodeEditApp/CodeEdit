//
//  SidebarTextField.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/2/23.
//

import SwiftUI

struct SidebarTextField<LeadingAccessories: View, TrailingAccessories: View>: View {
    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.controlActiveState)
    private var controlActive

    @FocusState private var isFocused: Bool

    var label: String

    @Binding private var text: String

    let leadingAccessories: LeadingAccessories?

    let trailingAccessories: TrailingAccessories?

    init(
        _ label: String,
        text: Binding<String>,
        @ViewBuilder leadingAccessories: () -> LeadingAccessories? = { EmptyView() },
        @ViewBuilder trailingAccessories: () -> TrailingAccessories? = { EmptyView() }
    ) {
        self.label = label
        _text = text
        self.leadingAccessories = leadingAccessories()
        self.trailingAccessories = trailingAccessories()
    }

    @ViewBuilder
    public func selectionBackground(
        _ isFocused: Bool = false
    ) -> some View {
        if self.controlActive != .inactive {
            if isFocused || !text.isEmpty {
                if colorScheme == .light {
                    Color.white
                } else {
                    Color(hex: 0x1e1e1e)
                }
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
        HStack(alignment: .center, spacing: 0) {
            if let leading = leadingAccessories {
                leading
            }
            VStack {
                TextField(label, text: $text, axis: .vertical)
                    .lineLimit(1...4)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .controlSize(.small)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundStyle(.primary)
            }
            if let trailing = trailingAccessories {
                trailing
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .buttonStyle(.icon(font: .system(size: 11, weight: .semibold), size: CGSize(width: 28, height: 22)))
        .padding(0.5)
        .background(selectionBackground(isFocused))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isFocused || !text.isEmpty ? .tertiary : .quaternary, lineWidth: 1.25)
                .cornerRadius(6)
                .disabled(true)
        )
    }
}

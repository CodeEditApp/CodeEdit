//
//  NavigatorFilterView.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/2/25.
//

import SwiftUI

struct NavigatorFilterView<
    MenuContents: View,
    LeadingAccessories: View,
    TrailingAccessories: View
>: View {
    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.controlActiveState)
    private var controlActive

    @FocusState private var isFocused: Bool

    @Binding var text: String
    let hasValue: Bool
    let menu: MenuContents
    let leadingAccessories: LeadingAccessories
    let trailingAccessories: TrailingAccessories

    init(
        text: Binding<String>,
        hasValue: (() -> Bool)? = nil,
        @ViewBuilder menu: () -> MenuContents,
        @ViewBuilder leadingAccessories: () -> LeadingAccessories,
        @ViewBuilder trailingAccessories: () -> TrailingAccessories
    ) {
        self._text = text
        self.hasValue = hasValue?() ?? false
        self.menu = menu()
        self.leadingAccessories = leadingAccessories()
        self.trailingAccessories = trailingAccessories()
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 5) {
                menu
                if #available(macOS 26, *) {
                    textField
                } else {
                    PaneTextField(
                        "Filter",
                        text: $text,
                        leadingAccessories: { leadingAccessories },
                        trailingAccessories: { trailingAccessories },
                        clearable: true,
                        hasValue: hasValue
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
        }
    }

    @available(macOS 26, *)
    @ViewBuilder var textField: some View {
        HStack(alignment: .center, spacing: 0) {
            leadingAccessories
            TextField("Filter", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .controlSize(.small)
                .padding(.horizontal, 8)
                .foregroundStyle(.primary)
                .font(.system(size: 13))
            Button {
                self.text = ""
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(buttonStyle)
            .opacity(text.isEmpty ? 0 : 1)
            .disabled(text.isEmpty)
            trailingAccessories
        }
        .padding(.horizontal, 3)
        .fixedSize(horizontal: false, vertical: true)
        .buttonStyle(buttonStyle)
        .toggleStyle(toggleStyle)
        .frame(minHeight: 28)
        .background(
            selectionBackground(isFocused)
                .clipShape(Capsule())
                .edgesIgnoringSafeArea(.all)
        )
        .overlay(
            Capsule()
                .stroke(isFocused || !text.isEmpty || hasValue ? .tertiary : .quaternary, lineWidth: 1.25)
                .clipShape(Capsule())
                .disabled(true)
                .edgesIgnoringSafeArea(.all)
        )
        .onTapGesture {
            isFocused = true
        }
    }

    @available(macOS 26, *)
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

    @available(macOS 26, *)
    private var buttonStyle: some ButtonStyle {
        .icon(font: .system(size: 16, weight: .semibold), size: CGSize(width: 20, height: 20))
    }
    @available(macOS 26, *)
    private var toggleStyle: some ToggleStyle {
        .icon(font: .system(size: 16, weight: .semibold), size: CGSize(width: 20, height: 20))
    }
}

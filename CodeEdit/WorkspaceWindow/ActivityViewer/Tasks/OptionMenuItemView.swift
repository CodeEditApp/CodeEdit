//
//  OptionMenuItemView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 24.06.24.
//

import SwiftUI

struct OptionMenuItemView: View {
    var label: String
    var action: () -> Void

    var body: some View {
        HStack {
            Text(label)
            Spacer()
        }
        .padding(.horizontal, 20)
        .dropdownItemStyle()
        .onTapGesture {
            action()
        }
        .accessibilityElement()
        .accessibilityAction {
            action()
        }
        .accessibilityLabel(label)
    }
}

#Preview {
    OptionMenuItemView(label: "Test") {
        print("test")
    }
}

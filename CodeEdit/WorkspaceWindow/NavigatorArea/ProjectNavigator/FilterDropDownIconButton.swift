//
//  FilterDropDownIconButton.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/2/25.
//

import SwiftUI

struct FilterDropDownIconButton<MenuView: View>: View {
    @Environment(\.controlActiveState)
    private var activeState

    var menu: () -> MenuView

    var isOn: Bool?

    var body: some View {
        Menu { menu() } label: {}
            .background {
                if isOn == true {
                    Image(ImageResource.line3HorizontalDecreaseChevronFilled)
                        .foregroundStyle(.tint)
                } else {
                    Image(ImageResource.line3HorizontalDecreaseChevron)
                }
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .frame(width: 26, height: 13)
            .clipShape(.rect(cornerRadius: 6.5))
    }
}

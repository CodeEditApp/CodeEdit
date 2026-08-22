//
//  ButtonStyledMenu.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 08.09.24.
//

import SwiftUI

/// A menu styled to resemble a bordered button.
public struct ButtonStyledMenu<MenuView: View>: View {
    var systemImage: String
    var menu: () -> MenuView

    public init(systemImage: String, menu: @escaping () -> MenuView) {
        self.systemImage = systemImage
        self.menu = menu
    }

    public var body: some View {
        Menu { menu() } label: {}
            .background {
                Button {} label: {
                    HStack {
                        Image(systemName: systemImage)
                        Image(systemName: "chevron.down")
                            .resizable()
                            .fontWeight(.bold)
                            .frame(width: 8, height: 4.8)
                            .padding(.leading, -1.5)
                            .padding(.trailing, -2)
                    }.offset(y: 1)
                }
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .frame(width: 30)
    }
}

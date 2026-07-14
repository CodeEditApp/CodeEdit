//
//  StatusBarEncodingSelector.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

struct StatusBarEncodingSelector: View {

    var body: some View {
        Menu {
            // UTF 8, ASCII, ...
        } label: {
            Text("UTF 8")
        }
        .menuStyle(StatusBarMenuStyle())
        .onHover { isHovering($0) }
    }
}

//
//  StatusBarLineEndSelector.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

struct StatusBarLineEndSelector: View {

    var body: some View {
        Menu {
            // LF, CRLF
        } label: {
            Text("LF")
        }
        .menuStyle(StatusBarMenuStyle())
        .onHover { isHovering($0) }
    }
}

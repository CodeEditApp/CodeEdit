//
//  StatusBarSplitTerminalButton.swift
//  CodeEditModules/StatusBar
//
//  Created by Stef Kors on 14/04/2022.
//

import SwiftUI

struct StatusBarSplitTerminalButton: View {
    @EnvironmentObject private var model: UtilityAreaViewModel

    var body: some View {
        Button {
            // todo
        } label: {
            Image(systemName: "square.split.2x1")
        }
    }
}

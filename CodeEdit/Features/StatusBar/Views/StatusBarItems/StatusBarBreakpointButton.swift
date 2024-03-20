//
//  StatusBarBreakpointButton.swift
//  CodeEditModules/StatusBar
//
//  Created by Stef Kors on 14/04/2022.
//

import SwiftUI
import CodeEditSymbols

struct StatusBarBreakpointButton: View {
    @EnvironmentObject private var model: UtilityAreaViewModel

    var body: some View {
        Button {
            model.isBreakpointEnabled.toggle()
        } label: {
            if model.isBreakpointEnabled {
                Image.breakpointFill
                    .foregroundColor(.accentColor)
            } else {
                Image.breakpoint
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

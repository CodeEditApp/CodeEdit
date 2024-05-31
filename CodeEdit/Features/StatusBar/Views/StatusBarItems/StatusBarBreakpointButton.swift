//
//  StatusBarBreakpointButton.swift
//  CodeEdit
//
//  Created by Stef Kors on 14/04/2022.
//

import SwiftUI
import CodeEditSymbols

struct StatusBarBreakpointButton: View {
    @EnvironmentObject private var statusBarViewModel: StatusBarViewModel

    var body: some View {
        Button {
            statusBarViewModel.isBreakpointEnabled.toggle()
        } label: {
            if statusBarViewModel.isBreakpointEnabled {
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

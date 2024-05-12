//
//  StatusBarBreakpointButton.swift
//  CodeEdit
//
//  Created by Stef Kors on 14/04/2022.
//

import SwiftUI
import CodeEditSymbols

struct StatusBarBreakpointButton: View {
    // @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    @State private var isBreakpointEnabled = false

    var body: some View {
        Button {
            // utilityAreaViewModel.isBreakpointEnabled.toggle()
            isBreakpointEnabled.toggle()
        } label: {
            // if utilityAreaViewModel.isBreakpointEnabled {
            if isBreakpointEnabled {
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

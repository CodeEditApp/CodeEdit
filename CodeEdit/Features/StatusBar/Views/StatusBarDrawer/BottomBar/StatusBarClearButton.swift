//
//  StatusBarClearButton.swift
//  CodeEditModules/StatusBar
//
//  Created by Stef Kors on 12/04/2022.
//

import SwiftUI

struct StatusBarClearButton: View {
    @EnvironmentObject
    private var model: StatusBarViewModel

    var body: some View {
        Button {
            // Clear terminal
        } label: {
            Image(systemName: "trash")
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
    }
}

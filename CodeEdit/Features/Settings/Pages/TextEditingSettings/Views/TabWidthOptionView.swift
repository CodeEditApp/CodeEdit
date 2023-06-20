//
//  TabWidthOptionView.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/18/23.
//

import SwiftUI

struct TabWidthOptionView: View {
    @Binding var defaultTabWidth: Int

    var body: some View {
        HStack(alignment: .top) {
            Stepper(
                "Tab Width",
                value: Binding<Double>(
                    get: { Double(defaultTabWidth) },
                    set: { defaultTabWidth = Int($0) }
                ),
                in: 1...16,
                step: 1,
                format: .number
            )
            Text("spaces")
                .foregroundColor(.secondary)
        }
        .help("The visual width of tabs.")
    }
}

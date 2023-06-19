//
//  IndentOptionView.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/18/23.
//

import SwiftUI

struct IndentOptionView: View {
    @AppSettings(\.textEditing) private var textEditing

    var body: some View {
        Group {
            Picker("Prefer Indent Using", selection: $textEditing.indentOption.indentType) {
                Text("Tabs")
                    .tag(SettingsData.TextEditingSettings.IndentOption.IndentType.tab)
                Text("Spaces")
                    .tag(SettingsData.TextEditingSettings.IndentOption.IndentType.spaces)
            }
            if textEditing.indentOption.indentType == .spaces {
                HStack {
                    Stepper(
                        "Indent Width",
                        value: Binding<Double>(
                            get: { Double(textEditing.indentOption.spaceCount) },
                            set: { textEditing.indentOption.spaceCount = Int($0) }
                        ),
                        in: 0...10,
                        step: 1,
                        format: .number
                    )
                    Text("spaces")
                        .foregroundColor(.secondary)
                }
                .help("The number of spaces to insert when the tab key is pressed.")
            }
        }
    }
}

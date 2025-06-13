//
//  InvisiblesSettingsView.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/13/25.
//

import SwiftUI

struct InvisiblesSettingsView: View {
    @AppSettings(\.textEditing)
    var textEditing

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Section {
                        Toggle(isOn: $textEditing.invisibleCharacters.showSpaces) {
                            Text("Show Spaces")
                        }
                        Toggle(isOn: $textEditing.invisibleCharacters.showTabs) {
                            Text("Show Tabs")
                        }
                        Toggle(isOn: $textEditing.invisibleCharacters.showLineEndings) {
                            Text("Show Line Endings")
                        }
                    }
                    Section {
                        InvisibleCharacterWarningList(items: $textEditing.invisibleCharacters.warningCharacters)
                    } header: {
                        Text("Warning Characters")
                        Text(
                            "CodeEdit can help identify invisible or ambiguous characters, such as zero-width spaces," +
                            " directional quotes, and more. These will appear with a red block highlighting them." +
                            "You can disable characters or add more here."
                        )
                    }
                }
                .formStyle(.grouped)
                Divider()
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .frame(minWidth: 56)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Invisible Characters")
        }
    }
}

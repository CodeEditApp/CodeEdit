//
//  SearchSettingsView.swift
//  CodeEdit
//
//  Created by Esteban on 12/10/23.
//

import SwiftUI

struct SearchSettingsView: View {

    @ObservedObject private var searchSettingsModel: SearchSettingsModel = .shared

    @FocusState private var focusedField: String?
    @State private var selection: Set<String> = []

    func addIgnoreGlobPattern() {
        searchSettingsModel.ignoreGlobPatterns.append(GlobPattern(value: ""))
    }

    var body: some View {
        SettingsForm {
            Section {
                List($searchSettingsModel.ignoreGlobPatterns, selection: $selection) { ignorePattern in
                    TextField("", text: ignorePattern.value)
                        .disableAutocorrection(true)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: ignorePattern.id.uuidString)
                        .labelsHidden()
                        .onAppear {
                            if $searchSettingsModel.ignoreGlobPatterns.isEmpty {
                                addIgnoreGlobPattern()
                            }
                        }
                        .onSubmit {
                            if $searchSettingsModel.ignoreGlobPatterns.isEmpty {
                                print("Remove \(ignorePattern)")
                            } else {
                                if ignorePattern.id == $searchSettingsModel.ignoreGlobPatterns.last?.id {
                                    addIgnoreGlobPattern()
                                }
                            }
                        }
                }
                .actionBar {
                    Button {
                        addIgnoreGlobPattern()
                    } label: {
                        Image(systemName: "plus")
                    }
                    Divider()
                    Button {
                        print("Remove")
                    } label: {
                        Image(systemName: "minus")
                    }
                    .disabled($searchSettingsModel.ignoreGlobPatterns.isEmpty)
                    Spacer()
                    Button {
                        print("More")
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 13, weight: .medium))
                    }
                }
                .onDeleteCommand {
                    print("Remove selection")
                }
            }
        }
    }
}

//
//  SearchSettingsView.swift
//  CodeEdit
//
//  Created by Esteban on 12/10/23.
//

import SwiftUI

struct GlobPattern: Identifiable, Hashable {
    /// Ephimeral UUID used to track its representation in the UI
    let id = UUID()
    
    /// The Glob Pattern to render
    var value: String
}

struct SearchSettingsView: View {

    @AppSettings(\.search.ignoreGlobPatterns)
    var ignoreGlobPatterns

    @FocusState private var focusedField: String?
    @State private var selection: Set<String> = []

    @State var globPatterns: [GlobPattern] = []

    init() {
        globPatterns = ignoreGlobPatterns.map {
            GlobPattern(value: $0)
        }
    }

    func addIgnoreGlobPattern() {
        globPatterns.append(.init(value: ""))
    }

    var body: some View {
        SettingsForm {
            Section {
                List($globPatterns, id: \.self, selection: $selection) { $globPattern in
                    TextField("", text: $globPattern.value)
                        .focused($focusedField, equals: globPattern.id.uuidString)
                        .labelsHidden()
                        .onAppear {
                            if globPatterns.isEmpty {
                                addIgnoreGlobPattern()
                            }
                        }
                        .onSubmit {
                            if globPattern.value.isEmpty {
                                print("Remove \(globPattern)")
                            } else {
                                if globPattern == globPatterns.last {
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
                    .disabled(ignoreGlobPatterns.isEmpty)
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

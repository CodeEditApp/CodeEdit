//
//  UtilityAreaOutputSourcePicker.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/18/25.
//

import CodeEditCore
import CELSP
import SwiftUI
import CodeEditSettings

struct UtilityAreaOutputSourcePicker: View {
    typealias Sources = UtilityAreaOutputView.Sources

    @Environment(\.languageServerListState)
    private var languageServerListState

    @Binding var selectedSource: Sources?

    var body: some View {
        if let languageServerListState {
            ObservingContent(listState: languageServerListState, selectedSource: $selectedSource)
        } else {
            // Previews: the environment key is nil and the server list is legitimately empty.
            Content(runningServers: [], selectedSource: $selectedSource)
        }
    }

    /// Observes the server list and feeds it to ``Content`` as plain data. A separate view because
    /// `@ObservedObject` cannot hold the optional environment value directly.
    private struct ObservingContent: View {
        @ObservedObject var listState: LanguageServerListState
        @Binding var selectedSource: Sources?

        var body: some View {
            Content(runningServers: listState.runningServers, selectedSource: $selectedSource)
        }
    }

    private struct Content: View {
        @Environment(\.workspaceFileURL)
        private var workspaceFileURL

        @AppSettings(\.developerSettings.showInternalDevelopmentInspector)
        var showInternalDevelopmentInspector

        let runningServers: [RunningLanguageServer]

        @Binding var selectedSource: Sources?

        @ObservedObject var extensionManager = ExtensionManager.shared

        private var languageServerClients: [RunningLanguageServer] {
            runningServers
                .filter { $0.workspacePath == workspaceFileURL?.absolutePath }
                .sorted(by: { $0.languageId.rawValue < $1.languageId.rawValue })
        }

        var body: some View {
            Picker("Output Source", selection: $selectedSource) {
                if selectedSource == nil {
                    Text("No Selected Output Source")
                        .italic()
                        .tag(Sources?.none)
                    Divider()
                }

                if languageServerClients.isEmpty {
                    Text("No Language Servers")
                } else {
                    ForEach(languageServerClients, id: \.languageId) { server in
                        Text(Sources.languageServer(server.logContainer).title)
                            .tag(Sources.languageServer(server.logContainer))
                    }
                }

                Divider()

                if extensionManager.extensions.isEmpty {
                    Text("No Extensions")
                } else {
                    ForEach(extensionManager.extensions) { extensionInfo in
                        Text(Sources.extensions(.init(extensionInfo: extensionInfo)).title)
                            .tag(Sources.extensions(.init(extensionInfo: extensionInfo)))
                    }
                }

                if showInternalDevelopmentInspector {
                    Divider()
                    Text(Sources.devOutput.title)
                        .tag(Sources.devOutput)
                }
            }
            .buttonStyle(.borderless)
            .labelsHidden()
            .controlSize(.small)
            .onAppear {
                selectDefaultSourceIfNeeded()
            }
            .onChange(of: languageServerClients.map(\.id)) { _, _ in
                selectDefaultSourceIfNeeded()
            }
        }

        private func selectDefaultSourceIfNeeded() {
            if selectedSource == nil, let client = languageServerClients.first {
                selectedSource = Sources.languageServer(client.logContainer)
            }
        }
    }
}

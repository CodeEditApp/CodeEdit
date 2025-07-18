//
//  UtilityAreaOutputSourcePicker.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/18/25.
//

import SwiftUI

struct UtilityAreaOutputSourcePicker: View {
    typealias Sources = UtilityAreaOutputView.Sources

    @EnvironmentObject private var workspace: WorkspaceDocument

    @AppSettings(\.developerSettings.showInternalDevelopmentInspector)
    var showInternalDevelopmentInspector

    @Binding var selectedSource: Sources?

    @ObservedObject var extensionManager = ExtensionManager.shared

    @Service var lspService: LSPService
    @State private var updater: UUID = UUID()
    @State private var languageServerClients: [LSPService.LanguageServerType] = []

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
        .id(updater)
        .buttonStyle(.borderless)
        .labelsHidden()
        .controlSize(.small)
        .onAppear {
            updateLanguageServers(lspService.languageClients)
        }
        .onReceive(lspService.$languageClients) { clients in
            updateLanguageServers(clients)
        }
        .onReceive(extensionManager.$extensions) { _ in
            updater = UUID()
        }
    }

    func updateLanguageServers(_ clients: [LSPService.ClientKey: LSPService.LanguageServerType]) {
        languageServerClients = clients
            .compactMap { (key, value) in
                if key.workspacePath == workspace.fileURL?.absolutePath {
                    return value
                }
                return nil
            }
            .sorted(by: { $0.languageId.rawValue < $1.languageId.rawValue })
        if selectedSource == nil, let client = languageServerClients.first {
            selectedSource = Sources.languageServer(client.logContainer)
        }
        updater = UUID()
    }
}

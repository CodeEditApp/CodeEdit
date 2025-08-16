//
//  ExtensionsSettingsView.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import SwiftUI

struct LanguageServersView: View {
    @StateObject var registryManager: RegistryManager = .shared
    @StateObject private var searchModel = FuzzySearchUIModel<RegistryItem>()
    @State private var searchText: String = ""

    var body: some View {
        Group {
            SettingsForm {
                if registryManager.isDownloadingRegistry {
                    HStack {
                        Spacer()
                        ProgressView()
                            .controlSize(.small)
                        Spacer()
                    }
                }

                Section {
                    List(searchModel.items ?? registryManager.registryItems, id: \.name) { item in
                        LanguageServerRowView(
                            package: item,
                            onCancel: {
                                registryManager.cancelInstallation()
                            },
                            onInstall: { [item] in
                                do {
                                    try registryManager.startInstallation(package: item)
                                } catch {
                                    // TODO: Error handling
                                }
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                    }
                    .searchable(text: $searchText)
                    .onChange(of: searchText) { newValue in
                        searchModel.searchTextUpdated(searchText: newValue, allItems: registryManager.registryItems)
                    }
                }
            }
            .sheet(item: $registryManager.runningInstall) { operation in
                LanguageServerInstallView(operation: operation)
            }
        }
        .environmentObject(registryManager)
    }
}

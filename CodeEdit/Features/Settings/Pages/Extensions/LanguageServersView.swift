//
//  ExtensionsSettingsView.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import SwiftUI

/// Displays a searchable list of packages from the ``RegistryManager``.
struct LanguageServersView: View {
    @StateObject var registryManager: RegistryManager = .shared
    @State private var searchText: String = ""
    @State private var filteredItems: [RegistryItem]?
    @State private var selectedInstall: PackageManagerInstallOperation?

    var body: some View {
        VStack {
            SettingsForm {
                Section {
                    SearchField("Search", text: $searchText)
                }

                Section {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.footnote)
                            .foregroundColor(.yellow)
                        Text("Warning: Language server installation is experimental. Use at your own risk.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    if registryManager.isDownloadingRegistry {
                        HStack {
                            Spacer()
                            ProgressView()
                                .controlSize(.small)
                            Spacer()
                        }
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(
                                filteredItems ?? registryManager.registryItems,
                                id: \.name
                            ) { item in
                                Divider().padding(.horizontal, 10)
                                LanguageServerRowView(
                                    package: item,
                                    onCancel: {
                                        registryManager.cancelInstallation()
                                    },
                                    onInstall: { [item] in
                                        do {
                                            selectedInstall = try registryManager.installOperation(
                                                package: item
                                            )
                                        } catch {
                                            NSAlert(error: error).runModal()
                                        }
                                    }
                                )
                                .padding(10)
                            }
                        }
                        .padding(-10)
                    }
                }
            }
            .onChange(of: searchText) { _, newValue in
                if newValue.isEmpty {
                    filteredItems = nil
                } else {
                    let query = newValue.lowercased()
                    filteredItems = registryManager.registryItems.filter { item in
                        item.sanitizedName.lowercased().split(separator: " ").contains {
                            $0.hasPrefix(query)
                        }
                    }
                }
            }
            .sheet(item: $selectedInstall) { operation in
                LanguageServerInstallView(operation: operation)
            }
        }
        .environmentObject(registryManager)
    }
}

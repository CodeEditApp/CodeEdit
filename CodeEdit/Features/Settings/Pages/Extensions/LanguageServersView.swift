//
//  ExtensionsSettingsView.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import SwiftUI

struct LanguageServersView: View {
    @State private var didError = false
    @State private var installationFailure: InstallationFailure?
    @State private var registryItems: [RegistryItem] = []
    @State private var isLoading = true

    var body: some View {
        SettingsForm {
            Section {
                EmptyView()
            } header: {
                Label(
                    "Warning: Language server installation is not complete. Use this at your own risk. It "
                    + "**WILL** break.",
                    systemImage: "exclamationmark.triangle.fill"
                )
                .padding()
                .foregroundStyle(.black)
                .background(RoundedRectangle(cornerRadius: 12).fill(.yellow))
            }

            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .controlSize(.small)
                    Spacer()
                }
            } else {
                Section {
                    List(registryItems, id: \.name) { item in
                        LanguageServerRowView(
                            packageName: item.name,
                            subtitle: item.description,
                            isInstalled: RegistryManager.shared.installedLanguageServers[item.name] != nil,
                            isEnabled: RegistryManager.shared.installedLanguageServers[item.name]?.isEnabled ?? false,
                            onCancel: {
                                InstallationQueueManager.shared.cancelInstallation(packageName: item.name)
                            },
                            onInstall: {
                                let item = item // Capture for closure
                                InstallationQueueManager.shared.queueInstallation(package: item) { result in
                                    switch result {
                                    case .success:
                                        break
                                    case .failure(let error):
                                        didError = true
                                        installationFailure = InstallationFailure(error: error.localizedDescription)
                                    }
                                }
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                    }
                }
            }
        }
        .onAppear {
            loadRegistryItems()
        }
        .onReceive(NotificationCenter.default.publisher(for: .RegistryUpdatedNotification)) { _ in
            loadRegistryItems()
        }
        .onDisappear {
            InstallationQueueManager.shared.cleanUpInstallationStatus()
        }
        .alert(
            "Installation Failed",
            isPresented: $didError,
            presenting: installationFailure
        ) { _ in
            Button("Dismiss") { }
        } message: { details in
            Text(details.error)
        }
    }

    private func loadRegistryItems() {
        isLoading = true
        registryItems = RegistryManager.shared.registryItems
        if !registryItems.isEmpty {
            isLoading = false
        }
    }
}

private struct InstallationFailure: Identifiable {
    let error: String
    let id = UUID()
}

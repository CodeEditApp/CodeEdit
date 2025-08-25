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

    @State private var showingInfoPanel = false

    var body: some View {
        SettingsForm {
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
                } header: {
                    Label(
                        "Warning: Language server installation is experimental. Use at your own risk.",
                        systemImage: "exclamationmark.triangle.fill"
                    )
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
        .toolbar {
            Button {
                showingInfoPanel.toggle()
            } label: {
                Image(systemName: "questionmark.circle")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .popover(isPresented: $showingInfoPanel, arrowEdge: .top) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Language Server Installation").font(.title2)
                        Spacer()
                    }
                    .frame(width: 300)
                    Text(getInfoString())
                        .lineLimit(nil)
                        .frame(width: 300)
                }
                .padding()
            }
        }
    }

    private func loadRegistryItems() {
        isLoading = true
        registryItems = RegistryManager.shared.registryItems
        if !registryItems.isEmpty {
            isLoading = false
        }
    }

    private func getInfoString() -> AttributedString {
        let string = "CodeEdit makes use of the Mason Registry for language server installation. To install a package, "
        + "CodeEdit uses the package manager directed by the Mason Registry, and installs a copy of "
        + "the language server in Application Support.\n\n"
        + "Language server installation is still experimental, there may be bugs and expect this flow "
        + "to change over time."

        var attrString = AttributedString(string)

        if let linkRange = attrString.range(of: "Mason Registry") {
            attrString[linkRange].link = URL(string: "https://mason-registry.dev/")
            attrString[linkRange].foregroundColor = NSColor.linkColor
        }

        return attrString
    }
}

private struct InstallationFailure: Identifiable {
    let error: String
    let id = UUID()
}

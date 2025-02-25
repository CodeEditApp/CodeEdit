//
//  ExtensionsSettingsView.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import SwiftUI

struct ExtensionsSettingsView: View {
    @State private var registryItems: [RegistryItem] = []
    @State private var isLoading = true

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
                        ExtensionsSettingsRowView(
                            title: item.name,
                            subtitle: item.description,
                            icon: "GitHubIcon",
                            onCancel: { }
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
    }

    private func loadRegistryItems() {
        isLoading = true
        registryItems = RegistryManager.shared.registryItems
        if !registryItems.isEmpty {
            isLoading = false
        }
    }
}

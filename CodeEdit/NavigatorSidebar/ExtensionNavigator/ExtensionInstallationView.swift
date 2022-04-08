//
//  ExtensionInstallationView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 8.04.22.
//

import SwiftUI
import ExtensionsStore

struct ExtensionInstallationView: View {
    var dismiss: () -> Void
    @ObservedObject var model: ExtensionInstallationViewModel

    var body: some View {
        VStack {
            Text(self.model.plugin.manifest.displayName)
                .font(.headline)
            Picker("Release", selection: $model.release) {
                ForEach(model.releases) { release in
                    Text(release.version)
                        .tag(release as PluginRelease?)
                }

                if !model.listFull {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear {
                            model.fetch()
                        }
                }
            }
        }
        .toolbar {
            HStack(spacing: 16.0) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                Button {
                    Task {
                        do {
                            if let release = self.model.release {
                                try await ExtensionsManager.shared?.install(plugin: self.model.plugin, release: release)
                                dismiss()
                            }
                        } catch let error {
                            print(error)
                        }
                    }
                } label: {
                    Text("Install")
                }
            }
        }
    }
}

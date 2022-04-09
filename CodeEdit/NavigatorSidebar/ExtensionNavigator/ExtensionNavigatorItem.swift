//
//  ExtensionNavigatorItem.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 7.04.22.
//

import SwiftUI
import ExtensionsStore

struct ExtensionNavigatorItem: View {
    init(plugin: Plugin) {
        self.plugin = plugin
        self.installed = ExtensionsManager.shared?.isInstalled(plugin: plugin) ?? false
    }

    var plugin: Plugin
    @State var showing = false
    @State var reopenAlert = false
    @State var installed: Bool = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(plugin.manifest.displayName)
                    .font(.headline)
                Text(plugin.manifest.name)
                    .font(.subheadline)
            }
            Spacer()
            if !installed {
                Button {
                    self.showing = true
                } label: {
                    Label("INSTALL", systemImage: "square.and.arrow.down")
                        .font(.callout.bold())
                        .accentColor(Color.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Button {
                    do {
                        try ExtensionsManager.shared?.remove(plugin: plugin)
                        self.installed = false
                    } catch let error {
                        print(error)
                    }
                } label: {
                    Label("UNINSTALL", systemImage: "trash")
                        .font(.callout.bold())
                        .accentColor(Color.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .sheet(isPresented: $showing) {

        } content: {
            ExtensionInstallationView(dismiss: {
                self.showing = false
                self.installed = ExtensionsManager.shared?.isInstalled(plugin: plugin) ?? false

                if self.installed {
                    self.reopenAlert = true
                }
            }, model: .init(plugin: plugin))
                .frame(width: 500, height: 400, alignment: .center)
        }
        .alert("Extension is installed", isPresented: $reopenAlert) {
            Button("OK") {
                self.reopenAlert = false
            }
        } message: {
            Text("To make extension work, you need to reopen the workspace.")
        }
        .padding(.vertical)
        .onAppear {
            self.installed = ExtensionsManager.shared?.isInstalled(plugin: plugin) ?? false
        }
    }
}

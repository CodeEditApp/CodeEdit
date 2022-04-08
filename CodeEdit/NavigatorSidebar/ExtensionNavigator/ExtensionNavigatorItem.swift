//
//  ExtensionNavigatorItem.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 7.04.22.
//

import SwiftUI
import ExtensionsStore

struct ExtensionNavigatorItem: View {
    var plugin: Plugin
    @State var showing = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(plugin.manifest.displayName)
                    .font(.headline)
                Text(plugin.manifest.name)
                    .font(.subheadline)
            }
            Spacer()
            Button {
                self.showing = true
            } label: {
                Label("INSTALL", systemImage: "square.and.arrow.down")
                    .font(.callout.bold())
                    .accentColor(Color.primary)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.accentColor)
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $showing) {

        } content: {
            ExtensionInstallationView(dismiss: {
                self.showing = false
            }, model: .init(plugin: plugin))
                .frame(width: 500, height: 400, alignment: .center)
        }
        .padding(.vertical)
    }
}

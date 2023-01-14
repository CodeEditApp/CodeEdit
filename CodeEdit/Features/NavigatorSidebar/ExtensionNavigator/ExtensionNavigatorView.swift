//
//  ExtensionNavigatorView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 6.04.22.
//

import SwiftUI
import Combine

struct ExtensionNavigatorView: View {
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @State var showing = false

    var body: some View {
        VStack {
            Divider() // TODO: fix this workaround because when switching tabs without this, the app crashes
            List {
                ForEach(workspace.extensionNavigatorData.plugins) { plugin in
                    ExtensionNavigatorItemView(plugin: plugin)
                        .tag(plugin)
                }

                if !workspace.extensionNavigatorData.listFull {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .onAppear {
                                workspace.extensionNavigatorData.fetch()
                            }
                        Spacer()
                    }
                }
            }
            .listStyle(.sidebar)
            .listRowInsets(.init())
        }
    }
}

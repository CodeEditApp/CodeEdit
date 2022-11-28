//
//  ExtensionNavigator.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 6.04.22.
//

import SwiftUI
import Combine

struct ExtensionNavigator: View {
    @EnvironmentObject var workspace: WorkspaceDocument
    @ObservedObject var data: ExtensionNavigatorData
    @State var showing = false

    var body: some View {
        VStack {
            Divider() // TODO: fix this workaround because when switching tabs without this, the app crashes
            List {
                ForEach(data.plugins) { plugin in
                    ExtensionNavigatorItem(plugin: plugin)
                        .tag(plugin)
                        .environmentObject(workspace)
                }

                if !data.listFull {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .onAppear {
                                data.fetch()
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

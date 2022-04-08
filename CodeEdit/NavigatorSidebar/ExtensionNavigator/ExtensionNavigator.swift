//
//  ExtensionNavigator.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 6.04.22.
//

import SwiftUI
import Combine
import ExtensionsStore

struct ExtensionNavigator: View {
    @ObservedObject var data: ExtensionNavigatorData
    @State var showing = false

    var body: some View {
        List {
            ForEach(data.plugins) { plugin in
                ExtensionNavigatorItem(plugin: plugin)
            }

            if !data.listFull {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .onAppear {
                        data.fetch()
                    }
            }
        }
        .listStyle(.sidebar)
        .listRowInsets(.init())

    }
}

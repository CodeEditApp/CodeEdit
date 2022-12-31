//
//  ExtensionList.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 30/12/2022.
//

import SwiftUI

struct ExtensionList: View {
    @EnvironmentObject var manager: ExtensionManager
    @Binding var selectedExtension: CEExtension?

    var body: some View {
        List(manager.extensions, id: \.bundleIdentifier, selection: $selectedExtension) { ex in
            NavigationLink(value: ex) {
                Text(ex.localizedName)
            }
        }
        .task {
            await manager.discover()
        }
        .toolbar {
            Button {
                Task {
                    await manager.discover()
                }
            } label: {
                Image(systemName: "arrow.counterclockwise")
            }
        }
    }
}

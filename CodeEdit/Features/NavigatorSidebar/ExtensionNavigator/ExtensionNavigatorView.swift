//
//  ExtensionNavigatorView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 6.04.22.
//

import SwiftUI
import Combine

struct ExtensionNavigatorView: View {
    @EnvironmentObject var workspace: WorkspaceDocument
    @EnvironmentObject var extensionManager: ExtensionManager

    @State var showing = false

    var body: some View {
        List {
            ExtensionActivatorView()
            ForEach(extensionManager.extensions) { ext in
                HStack {
                    if let icon = ext.icon {
                        Image(nsImage: icon)
                    } else {
                        Text("No Image")
                    }
                    Text(ext.name)
                }
            }
        }
        .toolbar {
            
            ToolbarItem {
                Button("HEllo") {

                }
            }
        }
    }
}

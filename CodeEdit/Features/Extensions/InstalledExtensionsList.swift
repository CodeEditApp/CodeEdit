//
//  InstalledExtensionsList.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 02/01/2023.
//

import SwiftUI

struct InstalledExtensionsList: View {
    @EnvironmentObject var manager: ExtensionDiscovery
    @EnvironmentObject var navigationManager: ExtensionWindowNavigationManager

    var body: some View {
        // ID should be self, otherwise .contextMenu will not work
        List(selection: $navigationManager.installedSelection) {
            ForEach(manager.extensions, id: \.self) { ext in
                HStack {
                    if let icon = ext.icon {
                        Image(nsImage: icon)
                    }
                    VStack(alignment: .leading) {
                        Text(ext.name)
                    }
                }
            }
        }

        // Prevents List with Image + transition out of bounds bug
        // .listStyle(.inset) fixes this too but slightly changes style
        .border(.red, width: 0)

        .onDeleteCommand {
            print("Delete")
        }

        .contextMenu(forSelectionType: ExtensionInfo.self) { selection in
            switch selection.count {
            case 0:
                Button("Add Local Extension") {}
                Button("Create Extension") {}
            case 1:
                Button("Delete") {}
            default:
                Button("Delete All") {}
            }
        }
    }
}


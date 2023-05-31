//
//  ExtensionsListView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 24/03/2023.
//

import SwiftUI

struct ExtensionsListView: View {
    @EnvironmentObject var manager: ExtensionManager
    @Binding var selection: Set<ExtensionInfo>
    @State var showActivatorView = false

    var body: some View {
        List(manager.extensions, id: \.self, selection: $selection) { ext in
            HStack {
                if let icon = ext.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                }

                VStack(alignment: .leading) {
                    Text(ext.name)
                    if let version = ext.version {
                        Text(version)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 40)
        }

        .toolbar {
            Toggle(isOn: $showActivatorView) {
                Image(systemName: "puzzlepiece.extension")
            }
            .toggleStyle(.button)
            .popover(isPresented: $showActivatorView) {
                ExtensionActivatorView()
                    .frame(width: 400, height: 300)
            }
        }
        .onChange(of: manager.extensions) { [oldValue = manager.extensions] newValue in
            // Select the first one if previously the extension list was empty.
            if oldValue.isEmpty, let first = newValue.first {
                selection = [first]
            }
        }
    }
}

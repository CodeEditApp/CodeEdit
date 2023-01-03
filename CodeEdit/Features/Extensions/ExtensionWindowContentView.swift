//
//  ExtensionWindowContentView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 01/01/2023.
//

import SwiftUI

enum SearchScope: Identifiable, CaseIterable, CustomStringConvertible {
    case installed
    case store

    var id: Self { self }

    var description: String {
        switch self {
        case .installed:
            return "Installed"
        case .store:
            return "Explore"
        }
    }
}

struct ExtensionWindowContentView: View {
    @EnvironmentObject var extensionDiscovery: ExtensionDiscovery
    @StateObject var manager = ExtensionWindowNavigationManager()
    @State var scope: SearchScope = .installed
    @State var showExtensionActivator = false

    var body: some View {
        NavigationSplitView {
            ExtensionList(scope: $scope)
                .environmentObject(manager)
                .toolbar {
                    ToolbarItem {
                        Button {
                            showExtensionActivator.toggle()
                        } label: {
                            Image(systemName: "puzzlepiece.extension")
                        }
                        .popover(isPresented: $showExtensionActivator) {
                            ExtensionActivatorView()
                                .frame(width: 400, height: 300)
                        }
                    }
                }
        } detail: {
            switch scope {
            case .installed:
                switch manager.installedSelection.count {
                case 0:
                    Text("Select an extension")
                case 1:
                    ExtensionDetailView(ext: manager.installedSelection.first!)
                default:
                    Text("More selected")
                }

            case .store:
                NavigationStack {
                    Text("Store")
                        .navigationDestination(for: StoreCategories.self) { category in
                            Text(category.description)
                        }
                        .navigationDestination(for: Int.self) {
                            Text(String($0))
                        }
                }
            }
        }
    }
}

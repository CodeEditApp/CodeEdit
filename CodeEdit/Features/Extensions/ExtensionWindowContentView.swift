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
                .navigationSplitViewColumnWidth(min: 250, ideal: 250)
                .toolbar {
                    // Doesn't work atm in NSWindow.
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

    /// Helper function which opens welcome view
    /// TODO: Move this to WelcomeModule after CodeEditDocumentController is in separate module
    static func openExtensionsWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 460),
            styleMask: [.titled, .fullSizeContentView, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.toolbarStyle = .unified
        window.center()

        let windowController = NSWindowController(window: window)

        let rootView = ExtensionWindowContentView()
            .environmentObject(ExtensionDiscovery.shared)

        window.contentView = NSHostingView(rootView: rootView)
        window.makeKeyAndOrderFront(self)
    }
}

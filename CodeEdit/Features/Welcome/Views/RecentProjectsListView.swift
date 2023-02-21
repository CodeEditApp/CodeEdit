//
//  RecentProjectsList.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 02/02/2023.
//

import SwiftUI

struct RecentProjectsListView: View {

    @State private var selection: Set<URL>

    private let openDocument: (URL?, @escaping () -> Void) -> Void
    private let dismissWindow: () -> Void

    @State var recentProjects: [URL]

    init(openDocument: @escaping (URL?, @escaping () -> Void) -> Void, dismissWindow: @escaping () -> Void) {
        self.openDocument = openDocument
        self.dismissWindow = dismissWindow
        let projects = NSDocumentController.shared.recentDocumentURLs
        self.recentProjects = projects
        self._selection = .init(wrappedValue: Set(Array(projects.prefix(1))))
    }

    var body: some View {
        if recentProjects.isEmpty {
            VStack {
                Spacer()
                Text(NSLocalizedString("No Recent Projects", comment: ""))
                    .font(.system(size: 20))
                Spacer()
            }
        } else {
            List(recentProjects, id: \.self, selection: $selection) { project in
                RecentProjectItem(projectPath: project)
            }
            .listStyle(.sidebar)
            .contextMenu(forSelectionType: URL.self) { items in
                switch items.count {
                case 0:
                    EmptyView()
                default:
                    Button("Show in Finder") {
                        NSWorkspace.shared.activateFileViewerSelecting(Array(items))
                    }

                    Button("Copy path\(items.count > 1 ? "s" : "")") {
                        let pasteBoard = NSPasteboard.general
                        pasteBoard.clearContents()
                        pasteBoard.writeObjects(selection.map(\.relativePath) as [NSString])
                    }

                    Button("Remove from Recents") {
                        let oldItems = NSDocumentController.shared.recentDocumentURLs
                        NSDocumentController.shared.clearRecentDocuments(nil)
                        oldItems.filter { !items.contains($0) }.reversed().forEach { url in
                            NSDocumentController.shared.noteNewRecentDocumentURL(url)
                        }

                        recentProjects = NSDocumentController.shared.recentDocumentURLs
                    }
                }
            } primaryAction: { items in
                items.forEach {
                    openDocument($0, dismissWindow)
                }
            }
            .onCopyCommand {
                selection.map {
                    NSItemProvider(object: $0.path(percentEncoded: false) as NSString)
                }
            }
            .onDeleteCommand {
                let oldItems = NSDocumentController.shared.recentDocumentURLs
                NSDocumentController.shared.clearRecentDocuments(nil)
                oldItems.filter { !selection.contains($0) }.reversed().forEach { url in
                    NSDocumentController.shared.noteNewRecentDocumentURL(url)
                }

                recentProjects = NSDocumentController.shared.recentDocumentURLs
            }
            .background(EffectView(.underWindowBackground, blendingMode: .behindWindow))
            .onReceive(NSApp.publisher(for: \.keyWindow)) { _ in
                // Update the list whenever the key window changes.
                // Ideally, this should be 'whenever a doc opens/closes'.
                recentProjects = NSDocumentController.shared.recentDocumentURLs
            }
            .background {
                Button("") {
                    selection.forEach {
                        openDocument($0, dismissWindow)
                    }
                }
                .keyboardShortcut(.defaultAction)
                .hidden()
            }
        }
    }
}

//
//  RecentProjectsListView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 02/02/2023.
//

import SwiftUI
import CoreSpotlight

struct RecentProjectsListView: View {

    @State private var selection: Set<URL>
    @State var recentProjects: [URL]

    private let openDocument: (URL?, @escaping () -> Void) -> Void
    private let dismissWindow: () -> Void

    init(openDocument: @escaping (URL?, @escaping () -> Void) -> Void, dismissWindow: @escaping () -> Void) {
        self.openDocument = openDocument
        self.dismissWindow = dismissWindow
        self._recentProjects = .init(initialValue: RecentProjectsStore.recentProjectURLs())
        self._selection = .init(initialValue: Set(RecentProjectsStore.recentProjectURLs().prefix(1)))
    }

    var listEmptyView: some View {
        VStack {
            Spacer()
            Text(NSLocalizedString("No Recent Projects", comment: ""))
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    var body: some View {
        List(recentProjects, id: \.self, selection: $selection) { project in
            RecentProjectListItem(projectPath: project)
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
                    removeRecentProjects()
                }
            }
        } primaryAction: { items in
            items.forEach { openDocument($0, dismissWindow) }
        }
        .onCopyCommand {
            selection.map { NSItemProvider(object: $0.path(percentEncoded: false) as NSString) }
        }
        .onDeleteCommand {
            removeRecentProjects()
        }
        .background(EffectView(.underWindowBackground, blendingMode: .behindWindow))
        .background {
            Button("") {
                selection.forEach { openDocument($0, dismissWindow) }
            }
            .keyboardShortcut(.defaultAction)
            .hidden()
        }
        .overlay {
            Group {
                if recentProjects.isEmpty {
                    listEmptyView
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: RecentProjectsStore.didUpdateNotification)) { _ in
            updateRecentProjects()
        }
    }

    func removeRecentProjects() {
        recentProjects = RecentProjectsStore.removeRecentProjects(selection)
    }

    func updateRecentProjects() {
        recentProjects = RecentProjectsStore.recentProjectURLs()
    }
}

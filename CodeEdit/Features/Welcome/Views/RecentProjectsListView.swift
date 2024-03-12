//
//  RecentProjectsList.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 02/02/2023.
//

import SwiftUI

struct RecentProjectsListView: View {

    @State private var selection: Set<URL>
    @State var recentProjects: [URL]

    private let openDocument: (URL?, @escaping () -> Void) -> Void
    private let dismissWindow: () -> Void

    init(openDocument: @escaping (URL?, @escaping () -> Void) -> Void, dismissWindow: @escaping () -> Void) {
        self.openDocument = openDocument
        self.dismissWindow = dismissWindow

        let recentProjectPaths: [String] = UserDefaults.standard.array(
            forKey: "recentProjectPaths"
        ) as? [String] ?? []
        let projectsURL = recentProjectPaths.map { URL(filePath: $0) }
        _selection = .init(initialValue: Set(projectsURL.prefix(1)))
        _recentProjects = .init(initialValue: projectsURL)
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
                    removeRecentProjects(items)
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
            removeRecentProjects(selection)
        }
        .background(EffectView(.underWindowBackground, blendingMode: .behindWindow))
        .onReceive(NSApp.publisher(for: \.keyWindow)) { _ in
            // Update the list whenever the key window changes.
            // Ideally, this should be 'whenever a doc opens/closes'.
            updateRecentProjects()
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
        .overlay {
            Group {
                if recentProjects.isEmpty {
                    listEmptyView
                }
            }
        }
    }

    func removeRecentProjects(_ items: Set<URL>) {
        var recentProjectPaths: [String] = UserDefaults.standard.array(
            forKey: "recentProjectPaths"
        ) as? [String] ?? []
        items.forEach { url in
            recentProjectPaths.removeAll { url == URL(filePath: $0) }
            selection.remove(url)
        }
        UserDefaults.standard.set(recentProjectPaths, forKey: "recentProjectPaths")
        let projectsURL = recentProjectPaths.map { URL(filePath: $0) }
        recentProjects = projectsURL
    }

    func updateRecentProjects() {
        let recentProjectPaths: [String] = UserDefaults.standard.array(
            forKey: "recentProjectPaths"
        ) as? [String] ?? []
        let projectsURL = recentProjectPaths.map { URL(filePath: $0) }
        recentProjects = projectsURL
    }
}

//
//  RecentProjectsListView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 02/02/2023.
//

import SwiftUI
import CoreSpotlight

struct RecentProjectsListView: View {
    @Environment(\.colorScheme)
    var colorScheme

    @FocusState private var isFocused: Bool

    @State private var selection: Set<URL>
    @State private var recentProjects: [URL]
    @State private var eventMonitor: Any?

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
        .focused($isFocused)
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
        .background {
            if self.colorScheme == .dark {
                Color(.black).opacity(0.075)
                    .background(.thickMaterial)
            } else {
                Color(.white).opacity(0.6)
                    .background(.regularMaterial)
            }
        }
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
        .onAppear {
            isFocused = true
            // NOTE: workaround for FB16112506
            self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
                switch event.keyCode {
                case 126: // Up Arrow
                    return self.handleArrowUpKeyPressed() == .handled ? nil : event
                case 125: // Down Arrow
                    return self.handleArrowDownKeyPressed() == .handled ? nil : event
                case 76, 36: // Enter and Return Arrow
                    return self.handleReturnKeyPressed() == .handled ? nil : event
                default:
                    return event
                }
            }
        }
    }

    func removeRecentProjects() {
        recentProjects = RecentProjectsStore.removeRecentProjects(selection)
    }

    func updateRecentProjects() {
        recentProjects = RecentProjectsStore.recentProjectURLs()
    }

    // MARK: - Key Handling

    enum KeyHandlingResult {
        case handled
        case notHandled
    }

    @discardableResult
    private func handleArrowUpKeyPressed() -> KeyHandlingResult {
        guard let current = currentSelectedIndex() else {
            selection = Set(recentProjects.suffix(1)) // select last if none selected
            return .handled
        }
        if current > 0 {
            selection = [recentProjects[current - 1]]
            return .handled
        }
        return .handled
    }

    @discardableResult
    private func handleArrowDownKeyPressed() -> KeyHandlingResult {
        guard let current = currentSelectedIndex() else {
            selection = Set(recentProjects.prefix(1)) // select first if none selected
            return .handled
        }
        if current < recentProjects.count - 1 {
            selection = [recentProjects[current + 1]]
            return .handled
        }
        return .handled
    }

    @discardableResult
    private func handleReturnKeyPressed() -> KeyHandlingResult {
        guard let selected = selection.first else { return .notHandled }
        openDocument(selected, dismissWindow)
        return .handled
    }

    private func currentSelectedIndex() -> Int? {
        guard let selected = selection.first else { return nil }
        return recentProjects.firstIndex(of: selected)
    }
}

//
//  RecentProjectsView.swift
//  CodeEditModules/WelcomeModule
//
//  Created by Ziyuan Zhao on 2022/3/18.
//
import SwiftUI

struct RecentProjectsView: View {
    @State
    private var recentProjectPaths: [String]

    @State
    private var selectedProjectPaths = Set<String>()

    @State
    private var lastSelectedProjectPath = String()

    private let openDocument: (URL?, @escaping () -> Void) -> Void
    private let dismissWindow: () -> Void

    var mgr = KeybindingManager.shared

    init(
        openDocument: @escaping (URL?, @escaping () -> Void) -> Void,
        dismissWindow: @escaping () -> Void
    ) {
        self.openDocument = openDocument
        self.dismissWindow = dismissWindow
        self.recentProjectPaths = UserDefaults.standard.array(forKey: "recentProjectPaths") as? [String] ?? []
    }

    private var emptyView: some View {
        VStack {
            Spacer()
            Text(NSLocalizedString("No Recent Projects", comment: ""))
                .font(.system(size: 20))
            Spacer()
        }
    }

    func contextMenuShowInFinder(projectPath: String) -> some View {
        Group {
            Button(NSLocalizedString("Show in Finder", comment: "")) {
                if selectedProjectPaths.contains(projectPath) {
                    self.selectedProjectPaths.forEach { projectPath in
                        guard let url = URL(string: "file://\(projectPath)") else {
                            return
                        }
                        NSWorkspace.shared.activateFileViewerSelecting([url])
                    }
                } else {
                    guard let url = URL(string: "file://\(projectPath)") else {
                        return
                    }
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                }
            }
        }
    }

    func contextMenuCopy(path: String) -> some View {
        Group {
            Button(NSLocalizedString("Copy Path", comment: "")) {
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([.string], owner: nil)
                pasteboard.setString(path, forType: .string)
            }
        }
    }

    func contextMenuDelete(projectPath: String) -> some View {
        Group {
            Button(NSLocalizedString("Remove from Recent Projects", comment: "")) {
                if selectedProjectPaths.contains(projectPath) {
                    self.selectedProjectPaths.forEach { projectPath in
                        deleteFromRecent(item: projectPath)
                    }
                } else {
                    deleteFromRecent(item: projectPath)
                }
            }
        }
    }

    func deleteFromRecent(item: String) {
        self.recentProjectPaths.removeAll {
            $0 == item
        }

        UserDefaults.standard.set(
            self.recentProjectPaths,
            forKey: "recentProjectPaths"
        )
    }

    func deleteProject(projectPath: String) {
        self.selectedProjectPaths.forEach { projectPath in
            deleteFromRecent(item: projectPath)
        }
    }

    func openProject(projectPath: String) {
        if selectedProjectPaths.contains(projectPath) {
            selectedProjectPaths.forEach { projectPath in
                openDocument(
                    URL(fileURLWithPath: projectPath),
                    dismissWindow
                )
            }
        } else {
            openDocument(
                URL(fileURLWithPath: projectPath),
                dismissWindow
            )
        }
    }

    /// Update recent projects, and remove ones that no longer exist
    func updateRecentProjects() {
        recentProjectPaths = ( UserDefaults.standard.array(forKey: "recentProjectPaths") as? [String] ?? [] )
            .filter { FileManager.default.fileExists(atPath: $0) }

        UserDefaults.standard.set(
            self.recentProjectPaths,
            forKey: "recentProjectPaths"
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            updateRecentProjects()
        }
    }

    var body: some View {
        VStack(alignment: !recentProjectPaths.isEmpty ? .leading : .center, spacing: 10) {
            if !recentProjectPaths.isEmpty {
                List(recentProjectPaths, id: \.self, selection: $selectedProjectPaths) { projectPath in
                    ZStack {
                        RecentProjectItem(projectPath: projectPath)
                            .frame(width: 300)
                            .highPriorityGesture(TapGesture(count: 2).onEnded {
                                openProject(projectPath: projectPath)
                            })
                            .gesture(TapGesture().onEnded {
                                if NSEvent.modifierFlags.contains(.command) {
                                    self.lastSelectedProjectPath = projectPath
                                    selectedProjectPaths.insert(projectPath)
                                } else if NSEvent.modifierFlags.contains(.shift) {
                                    if let lastIndex = recentProjectPaths.firstIndex(of: lastSelectedProjectPath),
                                       let currentIndex = recentProjectPaths.firstIndex(of: projectPath) {
                                        if currentIndex > lastIndex {
                                            let projectPaths = Array(recentProjectPaths[lastIndex..<currentIndex+1])
                                            selectedProjectPaths = selectedProjectPaths.union(projectPaths)
                                        } else {
                                            let projectPaths = Array(recentProjectPaths[currentIndex..<lastIndex+1])
                                            selectedProjectPaths = selectedProjectPaths.union(projectPaths)
                                        }
                                    }
                                } else {
                                    self.lastSelectedProjectPath = projectPath
                                    selectedProjectPaths = [projectPath]
                                }
                            })
                            .contextMenu {
                                contextMenuShowInFinder(projectPath: projectPath)

                                if !selectedProjectPaths.contains(projectPath) {
                                    contextMenuCopy(path: projectPath)
                                        .keyboardShortcut(mgr.named(with: "copy").keyboardShortcut)
                                }

                                Divider()
                                contextMenuDelete(projectPath: projectPath)
                                    .keyboardShortcut(.init(.delete))
                            }

                            Button("") {
                                deleteProject(projectPath: projectPath)
                            }
                            .buttonStyle(.borderless)
                            .keyboardShortcut(.init(.delete))

                            Button("") {
                                let pasteboard = NSPasteboard.general
                                pasteboard.declareTypes([.string], owner: nil)
                                pasteboard.setString(projectPath, forType: .string)
                            }
                            .buttonStyle(.borderless)
                            .keyboardShortcut(mgr.named(with: "copy").keyboardShortcut)

                        Button("") {
                            openProject(projectPath: projectPath)
                        }
                        .buttonStyle(.borderless)
                        .keyboardShortcut(.defaultAction)
                    }
                }
                .listStyle(.sidebar)
            } else {
                emptyView
            }
        }
        .frame(width: 300)
        .background(
            EffectView(
                NSVisualEffectView.Material.underWindowBackground,
                blendingMode: NSVisualEffectView.BlendingMode.behindWindow
            )
        )
        .onAppear {
            // onAppear is called once, and therafter never again,
            // since the window is never release from memory.
            updateRecentProjects()
        }
    }
}

struct RecentProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentProjectsView(openDocument: { _, _ in }, dismissWindow: {})
    }
}

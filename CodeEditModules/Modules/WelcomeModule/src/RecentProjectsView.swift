//
//  RecentProjectsView.swift
//  CodeEditModules/WelcomeModule
//
//  Created by Ziyuan Zhao on 2022/3/18.
//
import SwiftUI
import WorkspaceClient
import CodeEditUI

public struct RecentProjectsView: View {
    @State private var recentProjectPaths: [String]
    @State private var selectedProjectPath: String? = ""

    private let openDocument: (URL?, @escaping () -> Void) -> Void
    private let dismissWindow: () -> Void

    public init(
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
            Text(NSLocalizedString("No Recent Projects", bundle: .module, comment: ""))
                .font(.system(size: 20))
            Spacer()
        }
    }

    func contextMenuShowInFinder(projectPath: String) -> some View {
        Group {
            Button(NSLocalizedString("Show in Finder", bundle: .module, comment: "")) {
                guard let url = URL(string: "file://\(projectPath)") else {
                    return
                }

                NSWorkspace.shared.activateFileViewerSelecting([url])
            }
        }
    }

    func contextMenuCopy(path: String) -> some View {
        Group {
            Button(NSLocalizedString("Copy Path", bundle: .module, comment: "")) {
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([.string], owner: nil)
                pasteboard.setString(path, forType: .string)
            }
        }
    }

    func contextMenuDelete(projectPath: String) -> some View {
        Group {
            Button(NSLocalizedString("Remove from Recent Projects", bundle: .module, comment: "")) {
                deleteFromRecent(item: projectPath)
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

    public var body: some View {
        VStack(alignment: !recentProjectPaths.isEmpty ? .leading : .center, spacing: 10) {
            if !recentProjectPaths.isEmpty {
                List(recentProjectPaths, id: \.self, selection: $selectedProjectPath) { projectPath in
                    ZStack {
                        RecentProjectItem(projectPath: projectPath)
                            .frame(width: 300)
                            .gesture(TapGesture(count: 2).onEnded {
                                openDocument(
                                    URL(fileURLWithPath: projectPath),
                                    dismissWindow
                                )
                            })
                            .simultaneousGesture(TapGesture().onEnded {
                                selectedProjectPath = projectPath
                            })
                            .contextMenu {
                                contextMenuShowInFinder(projectPath: projectPath)
                                contextMenuCopy(path: projectPath)
                                    .keyboardShortcut(.init("C", modifiers: [.command]))

                                Divider()
                                contextMenuDelete(projectPath: projectPath)
                                    .keyboardShortcut(.init(.delete))
                            }

                        if selectedProjectPath == projectPath {
                            Button("") {
                                deleteFromRecent(item: projectPath)
                            }
                            .buttonStyle(.borderless)
                            .keyboardShortcut(.init(.delete))

                            Button("") {
                                let pasteboard = NSPasteboard.general
                                pasteboard.declareTypes([.string], owner: nil)
                                pasteboard.setString(projectPath, forType: .string)
                            }
                            .buttonStyle(.borderless)
                            .keyboardShortcut(.init("C", modifiers: [.command]))
                        }

                        Button("") {
                            if let selectedProjectPath = selectedProjectPath {
                                openDocument(
                                    URL(fileURLWithPath: selectedProjectPath),
                                    dismissWindow
                                )
                            }
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

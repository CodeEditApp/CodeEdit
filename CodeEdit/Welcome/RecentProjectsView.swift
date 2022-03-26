//
//  RecentProjectsView.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/18.
//
import Introspect
import SwiftUI
import WelcomeModule
import WorkspaceClient

extension List {
    /// List on macOS uses an opaque background with no option for
    /// removing/changing it. listRowBackground() doesn't work either.
    /// This workaround works because List is backed by NSTableView.
    func removeBackground() -> some View {
        return introspectTableView { tableView in
            tableView.backgroundColor = .clear
            tableView.enclosingScrollView!.drawsBackground = false
        }
    }
}

struct RecentProjectsView: View {
    @State var recentProjectPaths: [String] = UserDefaults.standard.array(forKey: "recentProjectPaths") as?
    [String] ?? []
    @State var selectedProjectPath: String? = ""

    let dismissWindow: () -> Void

    private var emptyView: some View {
        VStack {
            Spacer()
            Text("No Recent Projects".localized())
                .font(.system(size: 20))
            Spacer()
        }
    }

    private func openDocument(path: String) {
        CodeEditDocumentController.shared.openDocument(
            withContentsOf: URL(fileURLWithPath: path), display: true
        ) { doc, _, _ in
            if doc != nil {
                dismissWindow()
            }
        }
    }

    func contextMenuShowInFinder(projectPath: String) -> some View {
        Group {
            Button("Show in Finder".localized()) {
                guard let url = URL(string: "file://\(projectPath)") else {
                    return
                }

                NSWorkspace.shared.activateFileViewerSelecting([url])
            }
        }
    }

    func contextMenuCopy(path: String) -> some View {
        Group {
            Button("Copy Path".localized()) {
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([.string], owner: nil)
                pasteboard.setString(path, forType: .string)
            }
        }
    }

    func contextMenuDelete(projectPath: String) -> some View {
        Group {
            Button("Remove from Recent Projects".localized()) {
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

    var body: some View {
        VStack(alignment: !recentProjectPaths.isEmpty ? .leading : .center, spacing: 10) {
            if !recentProjectPaths.isEmpty {
                List(recentProjectPaths, id: \.self, selection: $selectedProjectPath) { projectPath in
                    ZStack {
                        RecentProjectItem(projectPath: projectPath)
                            .frame(width: 300)
                            .gesture(TapGesture(count: 2).onEnded {
                                openDocument(path: projectPath)
                            })
                            .simultaneousGesture(TapGesture().onEnded {
                                selectedProjectPath = projectPath
                            })
                            .contextMenu {
                                contextMenuShowInFinder(projectPath: projectPath)
                                contextMenuCopy(path: projectPath)
                                    .keyboardShortcut(.init("C", modifiers: [.command, .shift]))

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
                            .keyboardShortcut(.init("C", modifiers: [.command, .shift]))
                        }

                        Button("") {
                            if let selectedProjectPath = selectedProjectPath {
                                openDocument(path: selectedProjectPath)
                            }
                        }
                        .buttonStyle(.borderless)
                        .keyboardShortcut(.defaultAction)
                    }
                }.removeBackground()
            } else {
                emptyView
            }
        }
        .frame(width: 300)
        .background(BlurView(material: NSVisualEffectView.Material.underWindowBackground,
                             blendingMode: NSVisualEffectView.BlendingMode.behindWindow))
        .onAppear {
            recentProjectPaths = UserDefaults.standard.array(forKey: "recentProjectPaths") as? [String] ?? []
        }
    }
}

struct RecentProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentProjectsView {

        }
    }
}

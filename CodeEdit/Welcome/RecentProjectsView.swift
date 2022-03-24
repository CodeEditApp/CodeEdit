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
        do {
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
                if isDir.boolValue {
                    let document = try WorkspaceDocument(contentsOf: URL(fileURLWithPath: path), ofType: "")
                    document.makeWindowControllers()
                    document.showWindows()
                    dismissWindow()
                } else {
                    CodeEditDocumentController.shared.openDocument(
                        withContentsOf: URL(fileURLWithPath: path), display: true
                    ) { _, _, _ in
                        dismissWindow()
                    }
                }
            }
        } catch {
            print(error)
        }
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

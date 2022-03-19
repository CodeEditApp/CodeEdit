//
//  RecentProjectsView.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI
import WelcomeModule

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
            let document = try WorkspaceDocument(contentsOf: URL(fileURLWithPath: path), ofType: "")
            document.makeWindowControllers()
            document.showWindows()
            dismissWindow()
        } catch {
            print(error)
        }
    }
    
    var body: some View {
        VStack(alignment: recentProjectPaths.count > 0 ? .leading : .center, spacing: 10) {
            if (recentProjectPaths.count > 0) {
                List(recentProjectPaths, id: \.self, selection: $selectedProjectPath) { projectPath in
                    ZStack {
                        RecentProjectItem(projectName: String(projectPath.split(separator: "/").last ?? ""), projectPath: projectPath)
                            .frame(width: 300)
                            .gesture(TapGesture(count: 2).modifiers(.all).onEnded {
                                openDocument(path: projectPath)
                            })
                            .simultaneousGesture(TapGesture().onEnded {
                                selectedProjectPath = projectPath
                            })
                            .keyboardShortcut(.defaultAction)
                        Button("") {
                            if let selectedProjectPath = selectedProjectPath {
                                openDocument(path: selectedProjectPath)
                            }
                        }
                        .buttonStyle(.borderless)
                        .keyboardShortcut(.defaultAction)
                    }
                }
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

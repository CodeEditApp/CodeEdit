//
//  RecentProjectsView.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI
import WelcomeModule

struct RecentProjectsView: View {
    @State var recentProjectPaths: [String] = UserDefaults.standard.array(forKey: "recentProjectPaths") as? [String] ?? []
    @State var selectedProjectPath: String = ""

    let dismissWindow: () -> Void

    private var emptyView: some View {
        VStack {
            Spacer()
            Text("No Recent Projects".localized())
                .font(.system(size: 20))
            Spacer()
        }
    }

    var body: some View {
        VStack(alignment: recentProjectPaths.count > 0 ? .leading : .center, spacing: 10) {
            if recentProjectPaths.count > 0 {
                ScrollView {
                    ForEach(recentProjectPaths, id: \.self) { projectPath in
                        RecentProjectItem(
                            isSelected: .constant(selectedProjectPath == projectPath),
                            projectName: String(projectPath.split(separator: "/").last ?? ""),
                            projectPath: projectPath
                        )
                            .frame(width: 300)
                            .gesture(TapGesture(count: 2).onEnded {
                                do {
                                    let document = try WorkspaceDocument(
                                        contentsOf: URL(fileURLWithPath: projectPath),
                                        ofType: ""
                                    )
                                    document.makeWindowControllers()
                                    document.showWindows()
                                    dismissWindow()
                                } catch {
                                    print(error)
                                }
                            })
                            .simultaneousGesture(TapGesture().onEnded {
                                selectedProjectPath = projectPath
                            })
                    }
                }
            } else {
                emptyView
            }
        }
        .frame(width: 300)
        .padding(10)
        .background(BlurView(material: NSVisualEffectView.Material.underWindowBackground, blendingMode: NSVisualEffectView.BlendingMode.behindWindow))
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

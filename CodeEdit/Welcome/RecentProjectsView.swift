//
//  RecentProjectsView.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI

struct RecentProjectsView: View {
    @State var recentProjectPaths: [String] = UserDefaults.standard.array(forKey: "recentProjectPaths") as? [String] ?? []
    @State var selectedProjectPath = ""
    let dismissWindow: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(recentProjectPaths, id: \.self) { projectPath in
                RecentProjectItem(isSelected: .constant(selectedProjectPath == projectPath), projectName: String(projectPath.split(separator: "/").last ?? ""), projectPath: projectPath)
                    .frame(width: 300)
                    .gesture(TapGesture(count: 2).onEnded {
                        do {
                            let document = try WorkspaceDocument(contentsOf: URL(fileURLWithPath: projectPath), ofType: "")
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
            Spacer()
        }
        .frame(width: 300)
        .padding(10)
        .background(Color(red: 70 / 255, green: 70 / 255, blue: 70 / 255))
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

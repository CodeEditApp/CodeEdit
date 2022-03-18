//
//  RecentProjectsView.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

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

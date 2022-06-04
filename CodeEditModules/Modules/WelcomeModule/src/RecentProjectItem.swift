//
//  RecentProjectView.swift
//  CodeEditModules/WelcomeModule
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI
import WorkspaceClient

extension String {
    func abbreviatingWithTildeInPath() -> String {
        return (self as NSString).abbreviatingWithTildeInPath
    }
}

public struct RecentProjectItem: View {
    let projectPath: String
    let doesExist: Bool

    public init(projectPath: String) {
        self.projectPath = projectPath
        self.doesExist = FileManager.default.fileExists(atPath: projectPath)
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: projectPath))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .opacity(doesExist ? 1.0 : 0.5)
            VStack(alignment: .leading) {
                HStack {
                    Text(projectPath.components(separatedBy: "/").last ?? "").font(.system(size: 13))
                        .lineLimit(1)
                        .opacity(doesExist ? 1.0 : 0.5)
                    if !doesExist {
                        Text("Project deleted or moved").font(.system(size: 10))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .lineLimit(1)
                            .opacity(0.5)
                    }
                }
                Text(projectPath.abbreviatingWithTildeInPath())
                    .font(.system(size: 11))
                    .lineLimit(1)
                    .truncationMode(.head)
                    .opacity(doesExist ? 1.0 : 0.5)
            }.padding(.trailing, 15)
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

struct RecentProjectItem_Previews: PreviewProvider {
    static var previews: some View {
        RecentProjectItem(projectPath: "/repos/CodeEdit")
            .frame(width: 300)
    }
}

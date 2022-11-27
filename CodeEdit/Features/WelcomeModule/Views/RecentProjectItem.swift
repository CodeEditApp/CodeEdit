//
//  RecentProjectView.swift
//  CodeEditModules/WelcomeModule
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI

extension String {
    func abbreviatingWithTildeInPath() -> String {
        (self as NSString).abbreviatingWithTildeInPath
    }
}

struct RecentProjectItem: View {
    let projectPath: String

    init(projectPath: String) {
        self.projectPath = projectPath
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: projectPath))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            VStack(alignment: .leading) {
                Text(projectPath.components(separatedBy: "/").last ?? "").font(.system(size: 13))
                    .lineLimit(1)
                Text(projectPath.abbreviatingWithTildeInPath())
                    .font(.system(size: 11))
                    .lineLimit(1)
                    .truncationMode(.head)
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

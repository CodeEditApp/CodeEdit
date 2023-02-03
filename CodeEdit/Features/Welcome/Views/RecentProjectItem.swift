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
    let projectPath: URL

    init(projectPath: URL) {
        self.projectPath = projectPath
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: projectPath.path(percentEncoded: false)))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            VStack(alignment: .leading) {
                Text(projectPath.lastPathComponent)
                    .font(.system(size: 13))
                    .lineLimit(1)
                Text(projectPath.path(percentEncoded: false).abbreviatingWithTildeInPath())
                    .font(.system(size: 11))
                    .lineLimit(1)
                    .truncationMode(.head)
            }.padding(.trailing, 15)
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

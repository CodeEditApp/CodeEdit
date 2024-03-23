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
//            Image(nsImage: NSWorkspace.shared.icon(forFile: projectPath.path(percentEncoded: false)))
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 32, height: 32)
            VStack(alignment: .leading) {
                Text(projectPath.lastPathComponent)
                    .foregroundColor(.primary)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                Text(projectPath.deletingLastPathComponent().path(percentEncoded: false).abbreviatingWithTildeInPath())
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                    .lineLimit(1)
                    .truncationMode(.head)
            }
        }
        .frame(height: 36)
        .contentShape(Rectangle())
    }
}

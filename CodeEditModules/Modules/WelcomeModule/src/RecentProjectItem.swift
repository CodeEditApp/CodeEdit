//
//  RecentProjectView.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI

public struct RecentProjectItem: View {
    @Binding public var isSelected: Bool
    var projectName: String = ""
    var projectPath: String = ""

    public init(isSelected: Binding<Bool>, projectName: String, projectPath: String) {
        self._isSelected = isSelected
        self.projectName = projectName
        self.projectPath = projectPath
    }

    public var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "folder")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24)
            VStack(alignment: .leading) {
                Text(projectName).font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                Text(projectPath)
                    .lineLimit(1)
                    .truncationMode(.head)
            }
            Spacer()
        }
        .padding(10)
        .background(isSelected ? Color.accentColor : .clear)
        .contentShape(Rectangle())
        .cornerRadius(8)
    }
}

struct RecentProjectItem_Previews: PreviewProvider {
    static var previews: some View {
        RecentProjectItem(isSelected: .constant(false), projectName: "CodeEdit", projectPath: "/repos/CodeEdit")
            .frame(width: 300)
        RecentProjectItem(isSelected: .constant(true), projectName: "CodeEdit", projectPath: "/repos/CodeEdit")
            .frame(width: 300)
    }
}

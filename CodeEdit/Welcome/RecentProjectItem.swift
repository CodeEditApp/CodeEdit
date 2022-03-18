//
//  RecentProjectView.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI

struct RecentProjectItem: View {
    @Binding var isSelected: Bool
    var projectName: String = ""
    var projectPath: String = ""
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "folder")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24)
            VStack(alignment: .leading) {
                Text(projectName).font(.system(size: 16, weight: .semibold))
                Text(projectPath)
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .background(isSelected ? Color.accentColor : .clear)
        .cornerRadius(4)
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

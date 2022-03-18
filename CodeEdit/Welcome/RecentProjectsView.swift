//
//  RecentProjectsView.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI

struct RecentProjectsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(0..<10) { index in
                RecentProjectItem(isSelected: .constant(false), projectName: "CodeEdit", projectPath: "/repos/CodeEdit")
                    .frame(width: 300)
            }
            Spacer()
        }
        .frame(width: 300)
        .padding(10)
        .background(Color(red: 70 / 255, green: 70 / 255, blue: 70 / 255))
    }
}

struct RecentProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentProjectsView()
    }
}

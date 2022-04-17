//
//  HistoryInspector.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI

struct HistoryInspector: View {
    var body: some View {
        VStack {
            HistoryItem(name: "lukepistrol",
                        description: "Merge pull request #229 from lukepistrol/main",
                        commitId: "020e6ff",
                        date: "4 hours ago")
            HistoryItem(name: "lukepistrol",
                        description: "remove invalid fixme from swiftlint config",
                        commitId: "aa1109e",
                        date: "4 hours ago")
            HistoryItem(name: "RayZhao1998",
                        description: "Fix breadcrumb value when selected file changed",
                        commitId: "c0d0857",
                        date: "Yesterday")
            HistoryItem(name: "nanashili",
                        description: "Files will now be highlighted when opening the finder",
                        commitId: "1f44964",
                        date: "2 days ago")
        }.padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
    }
}

struct HistoryInspector_Previews: PreviewProvider {
    static var previews: some View {
        HistoryInspector()
    }
}

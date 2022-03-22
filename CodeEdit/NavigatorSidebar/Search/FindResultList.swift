//
//  FindResultList.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import SwiftUI
import WorkspaceClient

struct FindResultList: View {
    @ObservedObject var state: WorkspaceDocument.SearchState
    @State var selectedResult: AttributedString?
    
    var body: some View {
        List(selection: $selectedResult) {
            ForEach(Array(state.searchResult.keys), id: \.self) { (file: WorkspaceClient.FileItem) in
                Section {
                    ForEach(state.searchResult[file] ?? [], id: \.self) { line in
                        HStack(alignment: .top) {
                            Image(systemName: "text.alignleft")
                                .font(.system(size: 12))
                                .padding(.top, 2)
                            Text(line)
                                .lineLimit(Int.max)
                                .foregroundColor(Color(nsColor: .secondaryLabelColor))
                                .font(.system(size: 12, weight: .light))
                        }
                        .padding(.leading, 15)
                        .tag(line)
                        .onTapGesture {
                            state.workspace.openFile(item: file)
                        }
                    }
                } header: {
                    HStack(alignment: .center) {
//                            Image(nsImage: NSWorkspace.shared.icon(forFile: fileURL.path))
//                                .frame(width: 13, height: 13)
                        Text(file.url.lastPathComponent)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(nsColor: NSColor.headerTextColor))
                        Text(file.url.path.replacingOccurrences(of: state.workspace.fileURL?.path ?? "", with: ""))
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            }
        }
    }
}

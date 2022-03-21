//
//  SidebarSearch.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/20.
//

import SwiftUI
import WorkspaceClient
import Combine

struct SidebarSearch: View {
    @ObservedObject var state: WorkspaceDocument.SearchState
    @State private var searchText: String = ""
    @State var selectedResult: AttributedString?

    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(nsColor: .secondaryLabelColor))
                    TextField("", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    if searchText.count > 0 {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(nsColor: .secondaryLabelColor))
                            .onTapGesture {
                                searchText = ""
                                state.search(searchText)
                            }
                    }
                }
                .padding(.vertical, 2)
                .padding(.horizontal, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            Divider()
            HStack(alignment: .center) {
                Text(
"\(Array(state.searchResult.values).flatMap {$0}.count) results in \(Array(state.searchResult.keys).count) files")
                    .font(.system(size: 10))
//                    .foregroundColor(Color(nsColor: ))
            }
            Divider()
            List(selection: $selectedResult) {
                ForEach(Array(state.searchResult.keys), id: \.self) { fileURL in
                    Section {
                        ForEach(state.searchResult[fileURL] ?? [], id: \.self) { line in
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
                        }
                    } header: {
                        HStack(alignment: .center) {
//                            Image(nsImage: NSWorkspace.shared.icon(forFile: fileURL.path))
//                                .frame(width: 13, height: 13)
                            Text(fileURL.lastPathComponent)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(nsColor: NSColor.headerTextColor))
                            Text(fileURL.path.replacingOccurrences(of: state.workspace.fileURL?.path ?? "", with: ""))
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }
            }
        }
        .onSubmit {
            state.search(searchText)
        }
    }
}

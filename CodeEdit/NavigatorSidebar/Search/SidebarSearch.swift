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
    @ObservedObject var workspace: WorkspaceDocument
    var windowController: NSWindowController

    @State private var searchText: String = ""
    @ObservedObject var searchManger: SearchManager = SearchManager()

    @State var selectedResult: String?

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
            List(selection: $selectedResult) {
                ForEach(Array(searchManger.searchResult.keys), id: \.url) { fileItem in
                    Section {
                        ForEach(searchManger.searchResult[fileItem] ?? [], id: \.self) { line in
                            HStack(alignment: .top) {
                                Image(systemName: "text.alignleft")
                                    .font(.system(size: 12))
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
                            Image(systemName: fileItem.fileIcon)
                                .font(.system(size: 13))
                            Text(fileItem.fileName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(nsColor: NSColor.headerTextColor))
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }
            }
        }
        .onSubmit {
            searchManger.search(searchText, workspaceClient: workspace.workspaceClient)
        }
    }
}

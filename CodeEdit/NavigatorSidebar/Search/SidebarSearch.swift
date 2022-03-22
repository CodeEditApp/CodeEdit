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

    var body: some View {
        VStack {
            VStack {
                SearchModeSelector()
                SearchBar(title: "", text: $searchText)
                HStack {
                    Spacer()
                    
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            Divider()
            HStack(alignment: .center) {
                Text(
"\(Array(state.searchResult.values).flatMap {$0}.count) results in \(Array(state.searchResult.keys).count) files")
                    .font(.system(size: 10))
//                    .foregroundColor(Color(nsColor: ))
            }
            Divider()
            FindResultList(state: state)
        }
        .onSubmit {
            state.search(searchText)
        }
    }
}

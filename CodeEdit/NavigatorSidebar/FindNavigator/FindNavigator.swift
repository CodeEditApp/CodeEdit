//
//  SidebarSearch.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/20.
//

import SwiftUI
import WorkspaceClient
import Search

struct FindNavigator: View {
    @ObservedObject
    var state: WorkspaceDocument.SearchState

    @State
    private var searchText: String = ""
//    private var mode: SearchModeModel = .Containing //

    private var foundFilesCount: Int {
        state.searchResult.filter {!$0.hasKeywordInfo}.count
    }

    private var foundResultsCount: Int {
        state.searchResult.filter {$0.hasKeywordInfo}.count
    }

    var body: some View {
        VStack {
            VStack {
                FindNavigatorModeSelector()
                FindNavigatorSearchBar(state: state, title: "", text: $searchText)
                HStack {
                    Spacer()
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            Divider()
            HStack(alignment: .center) {
                Text(
                    "\(foundResultsCount) results in \(foundFilesCount) files")
                    .font(.system(size: 10))
            }
            Divider()
            FindNavigatorResultList(state: state)
        }
        .onSubmit {
            let mode = SearchModeModel.IgnoreCase // test; need to figure out how to get mode here
            state.search(searchText, mode: mode)
        }
    }
}

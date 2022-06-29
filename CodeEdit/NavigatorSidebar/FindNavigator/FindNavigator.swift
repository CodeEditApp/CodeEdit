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
    private var state: WorkspaceDocument.SearchState

    @State
    private var searchText: String = ""

    @State var filters: [String] = ["Ignoring Case", "Matching Case"]
    @State
    var currentFilter: String = ""

    private var foundFilesCount: Int {
        state.searchResult.filter { !$0.hasKeywordInfo }.count
    }

    private var foundResultsCount: Int {
        state.searchResult.filter { $0.hasKeywordInfo }.count
    }

    init(state: WorkspaceDocument.SearchState) {
        self.state = state
    }

    var body: some View {
        VStack {
            VStack {
                FindNavigatorModeSelector()
                FindNavigatorSearchBar(state: state, title: "", text: $searchText)
                HStack {
                    Button {} label: {
                        Text("In Workspace")
                            .font(.system(size: 10))
                    }.buttonStyle(.borderless)
                    Spacer()
                    Menu {
                        Button(filters[0], action: {
                            currentFilter = filters[0]
                            state.ignoreCase = true
                            state.search(searchText)
                        })
                        Button(filters[1], action: {
                            currentFilter = filters[1]
                            state.ignoreCase = true
                            state.search(searchText)
                        })
                    } label: {
                        HStack {
                            Text(currentFilter)
                                .font(.system(size: 10))
                        }
                    }
                    .menuStyle(.borderlessButton)
                    .onAppear {
                        if currentFilter == "" {
                            currentFilter = filters[0]
                        }
                    }
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
            state.search(searchText)
        }
    }
}

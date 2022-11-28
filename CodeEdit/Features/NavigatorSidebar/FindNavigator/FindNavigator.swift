//
//  SidebarSearch.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/20.
//

import SwiftUI

struct FindNavigator: View {
    @ObservedObject
    private var state: WorkspaceDocument.SearchState

    @ObservedObject
    private var workspace: WorkspaceDocument

    @State
    private var searchText: String = ""

    enum Filters: String {
        case ignoring = "Ignoring Case"
        case matching = "Matching Case"
    }

    @State var currentFilter: String = ""

    private var foundFilesCount: Int {
        state.searchResult.count
    }

    private var foundResultsCount: Int {
        state.searchResult.count
    }

    init(workspace: WorkspaceDocument, state: WorkspaceDocument.SearchState) {
        self.workspace = workspace
        self.state = state
    }

    var body: some View {
        VStack {
            VStack {
                FindNavigatorModeSelector(state: state)
                FindNavigatorSearchBar(state: state, title: "", text: $searchText)
                HStack {
                    Button {} label: {
                        Text("In Workspace")
                            .font(.system(size: 10))
                    }.buttonStyle(.borderless)
                    Spacer()
                    Menu {
                        Button {
                            currentFilter = Filters.ignoring.rawValue
                            state.ignoreCase = true
                            state.search(searchText)
                        } label: {
                            Text(Filters.ignoring.rawValue)
                        }
                        Button {
                            currentFilter = Filters.matching.rawValue
                            state.ignoreCase = false
                            state.search(searchText)
                        } label: {
                            Text(Filters.matching.rawValue)
                        }
                    } label: {
                        HStack(spacing: 2) {
                            Spacer()
                            Text(currentFilter)
                                .foregroundColor(currentFilter == Filters.matching.rawValue ?
                                                 Color.accentColor : .primary)
                                .font(.system(size: 10))
                        }
                    }
                    .menuStyle(.borderlessButton)
                    .frame(width: currentFilter == Filters.ignoring.rawValue ? 80 : 88)
                    .onAppear {
                        if currentFilter == "" {
                            currentFilter = Filters.ignoring.rawValue
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            Divider()
            HStack(alignment: .center) {
                Text(
                    "\(state.searchResultCount) results in \(foundFilesCount) files")
                    .font(.system(size: 10))
            }
            Divider()
            FindNavigatorResultList(workspace: workspace)
        }
        .onSubmit {
            state.search(searchText)
        }
    }
}

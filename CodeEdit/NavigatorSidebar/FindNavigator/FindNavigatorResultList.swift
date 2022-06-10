//
//  SearchResultList.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import SwiftUI
import WorkspaceClient
import Search

struct FindNavigatorResultList: View {
    @ObservedObject
    private var state: WorkspaceDocument.SearchState

    @State
    private var selectedResult: SearchResultModel?

    init(state: WorkspaceDocument.SearchState, selectedResult: SearchResultModel? = nil) {
        self.state = state
        self.selectedResult = selectedResult
    }

    private var foundFiles: [SearchResultModel] {
        state.searchResult.filter { !$0.hasKeywordInfo }
    }

    private func getResultWith(_ file: WorkspaceClient.FileItem) -> [SearchResultModel] {
        state.searchResult.filter { $0.file == file && $0.hasKeywordInfo }
    }

    var body: some View {
        List(selection: $selectedResult) {
            ForEach(foundFiles, id: \.self) { (foundFile: SearchResultModel) in
                FindNavigatorResultFileItem(
                    state: state,
                    fileItem: foundFile.file, results: getResultWith(foundFile.file)) {
                        state.workspace.openTab(item: foundFile.file)
                    }
            }
        }
        .listStyle(.sidebar)
        .onChange(of: selectedResult) { newValue in
            if let file = newValue?.file {
                state.workspace.openTab(item: file)
            }
        }
    }
}

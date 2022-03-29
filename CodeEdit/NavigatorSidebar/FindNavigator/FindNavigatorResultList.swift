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
    var state: WorkspaceDocument.SearchState

    @State
    var selectedResult: SearchResultModel?

    private var foundFiles: [SearchResultModel] {
        return state.searchResult.filter {!$0.hasKeywordInfo}
    }

    private func getResultWith(_ file: WorkspaceClient.FileItem) -> [SearchResultModel] {
        return state.searchResult.filter {$0.file == file && $0.hasKeywordInfo}
    }

    var body: some View {
        List(selection: $selectedResult) {
            ForEach(foundFiles, id: \.self) { (foundFile: SearchResultModel) in
                FindNavigatorResultFileItem(
                    state: state,
                    fileItem: foundFile.file, results: getResultWith(foundFile.file)) {
                        state.workspace.openFile(item: foundFile.file)
                    }
            }
        }
        .listStyle(.sidebar)
        .background(.clear)
        .onChange(of: selectedResult) { newValue in
            if let file = newValue?.file {
                state.workspace.openFile(item: file)
            }
        }
    }
}

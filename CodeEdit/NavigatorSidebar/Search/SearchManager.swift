//
//  SearchManager.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/20.
//

import Foundation
import WorkspaceClient
import Combine

class SearchManager: ObservableObject {

    @Published var searchResult: [WorkspaceClient.FileItem: [String]] = [:]

    private var cancellables = Set<AnyCancellable>()

    func search(_ text: String, workspaceClient: WorkspaceClient?) {
        searchResult = [:]
        workspaceClient?
            .getFiles
            .sink { [weak self] files in
                guard let self = self else { return }
                files.forEach { fileItem in
                    let data = try? String(contentsOf: fileItem.url)
                    data?.split(separator: "\n").forEach { line in
                        if line.contains(text) {
                            var lines = self.searchResult[fileItem] ?? []
                            lines.append(String(line))
                            self.searchResult[fileItem] = lines
                        }
                    }
                }
                print(self.searchResult)
            }
            .store(in: &cancellables)
    }
}

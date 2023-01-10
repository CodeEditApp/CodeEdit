//
//  FileTree.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 07/01/2023.
//

import Foundation

struct FileTree: Identifiable, Hashable {
    static func == (lhs: FileTree, rhs: FileTree) -> Bool {
        lhs.url == rhs.url
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }

    var wrapper: FileWrapper

    var baseURL: URL

    var url: URL {
        baseURL.appending(path: wrapper.filename ?? "new")
    }

    var update: (FileWrapper, String) -> FileWrapper

    var id: URL { url }

    var children: [FileTree]? {
        guard wrapper.isDirectory else { return nil }
        return wrapper.fileWrappers?.values.sorted { $0.filename ?? "" < $1.filename ?? "" }.map {
            FileTree(wrapper: $0, baseURL: url) { wrapper, newValue in
                let oldWrapper = self.wrapper.fileWrappers![wrapper.filename!]!

                //                guard let oldWrapper else { return  }

                let newWrapper = FileWrapper(regularFileWithContents: newValue.data(using: .utf8)!)
                newWrapper.preferredFilename = oldWrapper.filename
                newWrapper.filename = oldWrapper.filename
                newWrapper.icon = oldWrapper.icon

                self.wrapper.removeFileWrapper(oldWrapper)
                self.wrapper.addFileWrapper(newWrapper)
                return newWrapper
            }
        }
    }

    mutating func updateSelf(with contents: String) {
        wrapper = self.update(wrapper, contents)
    }
}

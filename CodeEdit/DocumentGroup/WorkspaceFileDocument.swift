//
//  WorkspaceDocument.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 04/01/2023.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers


final class ReferenceWorkspaceFileDocument: ReferenceFileDocument {

    static var readableContentTypes: [UTType] = [.folder]

    @Published var root: WrappedFile

    @Published var baseRoot: FileWrapper

    @Published var currentFile: String = "" {
        didSet {
            currentFileTree?.updateSelf(with: currentFile)
        }
    }

    var currentWrapper: WrappedFile?

    @Published var currentFileTree: FileTree?

    func setCurrentFile(_ current: WrappedFile) {
        print("Setting current file to \(current.filename ?? "")")
        self.currentWrapper = current

        guard current.isRegularFile else { return }
        print("File is regular")
        self.currentFile = String(data: current.regularFileContents!, encoding: .utf8) ?? ""
    }

    func setCurrentFileTree(_ current: FileTree) {
        print("Setting current file to \(current.wrapper.filename ?? "")")
        self.currentFileTree = current

        guard current.wrapper.isRegularFile else { return }
        print("File is regular")
        if let contents = current.wrapper.regularFileContents {
            self.currentFile = String(data: contents, encoding: .utf8) ?? ""
        } else {
            self.currentFile = ""
        }
    }

    init() {
        root = WrappedFile(FileWrapper(), parent: nil)
        baseRoot = FileWrapper()
    }

    init(configuration: ReadConfiguration) throws {
        print("IS Directory? \(configuration.file.isDirectory)")
        root = WrappedFile(configuration.file, parent: nil)
        baseRoot = configuration.file
    }

    func snapshot(contentType: UTType) throws -> FileWrapper {

        return baseRoot
    }

//    func fileWrapper(snapshot: (String, String?), configuration: WriteConfiguration) throws -> FileWrapper {
//
//        guard let currentWrapper, let filename = snapshot.1 else {
//            // Create new file
//            let updatedWrapper = FileWrapper(regularFileWithContents: snapshot.0.data(using: .utf8)!)
//            updatedWrapper.filename = "new.txt"
//            updatedWrapper.preferredFilename = "new.txt"
//
//            (root as FileWrapper).addFileWrapper(updatedWrapper)
//            return root as FileWrapper
//
//        }
//        print("Saving.....")
//        let parent = currentWrapper.parent as FileWrapper?
//
//        // Match with name as classes can't be compared to each other.
//        let old = parent?.fileWrappers?[filename]
//        parent!.removeFileWrapper(old!)
//
//        let updatedWrapper = FileWrapper(regularFileWithContents: snapshot.0.data(using: .utf8)!)
//        updatedWrapper.filename = filename
//        updatedWrapper.preferredFilename = filename
//        parent?.addFileWrapper(updatedWrapper)
//
//        return root as FileWrapper
//    }

    func fileWrapper(snapshot: FileWrapper, configuration: WriteConfiguration) throws -> FileWrapper {


        return snapshot
    }

    func checkForChanges(url: URL) {

        guard root.matchesContents(of: url) else {
            try? root.read(from: url)
            return
        }
    }

}

class WrappedFile: FileWrapper {
    var parent: FileWrapper?

    init(_ wrapper: FileWrapper, parent: FileWrapper?) {
        if wrapper.isRegularFile {
            super.init(regularFileWithContents: wrapper.regularFileContents!)
        } else if wrapper.isDirectory {
            super.init(directoryWithFileWrappers: wrapper.fileWrappers!)
        } else {
            super.init(symbolicLinkWithDestinationURL: wrapper.symbolicLinkDestinationURL!)
        }
        self.parent = parent
        self.filename = wrapper.filename
    }

    required init?(coder inCoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(regularFileWithContents contents: Data) {
        super.init(regularFileWithContents: contents)
    }

    override init(directoryWithFileWrappers childrenByPreferredName: [String: FileWrapper]) {
        super.init(directoryWithFileWrappers: childrenByPreferredName)
    }

    override init(symbolicLinkWithDestinationURL url: URL) {
        super.init(symbolicLinkWithDestinationURL: url)
    }

    override init?(serializedRepresentation serializeRepresentation: Data) {
        super.init(serializedRepresentation: serializeRepresentation)
    }

    override init(url: URL, options: FileWrapper.ReadingOptions = []) throws {
        try super.init(url: url, options: options)
    }
}

//
//  FileInspectorModel.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/04/17.
//

import SwiftUI

public final class FileInspectorModel: ObservableObject {

    /// The base URL of the workspace
    private(set) var workspaceURL: URL

    @Published
    var fileTypeSelection: LanguageType.ID = "swift"
    @Published
    var fileURL: String = ""
    @Published
    var fileName: String = ""

    @Published
    var locationSelection: Location.ID = "relative_group"
    @Published
    var textEncodingSelection: TextEncoding.ID = "utf8"
    @Published
    var lineEndingsSelection: LineEndings.ID = "macos"
    @Published
    var indentUsingSelection: IndentUsing.ID = "spaces"

    @Published
    var languageTypeObjCList = FileTypeList.init().languageTypeObjCList
    @Published
    var sourcecodeCList = FileTypeList.init().sourcecodeCList
    @Published
    var sourcecodeCPlusList = FileTypeList.init().sourcecodeCPlusList
    @Published
    var sourcecodeSwiftList = FileTypeList.init().sourcecodeSwiftList
    @Published
    var sourcecodeAssemblyList = FileTypeList.init().sourcecodeAssemblyList
    @Published
    var sourcecodeScriptList = FileTypeList.init().sourcecodeScriptList
    @Published
    var sourcecodeVariousList = FileTypeList.init().sourcecodeVariousList
    @Published
    var propertyList = FileTypeList.init().propertyList
    @Published
    var shellList = FileTypeList.init().shellList
    @Published
    var machOList = FileTypeList.init().machOList
    @Published
    var textList = FileTypeList.init().textList
    @Published
    var audioList = FileTypeList.init().audioList
    @Published
    var imageList = FileTypeList.init().imageList
    @Published
    var videoList = FileTypeList.init().videoList
    @Published
    var archiveList = FileTypeList.init().archiveList
    @Published
    var otherList = FileTypeList.init().otherList

    @Published
    var locationList = [Location(name: "Absolute Path", id: "absolute"),
                            Location(name: "Relative to Group", id: "relative_group"),
                            Location(name: "Relative to Project", id: "relative_project"),
                            Location(name: "Relative to Developer Directory", id: "relative_developer_dir"),
                            Location(name: "Relative to Build Projects", id: "relative_build_projects"),
                            Location(name: "Relative to SDK", id: "relative_sdk")]

    @Published
    var textEncodingList = [TextEncoding(name: "Unicode (UTF-8)", id: "utf8"),
                            TextEncoding(name: "Unicode (UTF-16)", id: "utf16"),
                            TextEncoding(name: "Unicode (UTF-16BE)", id: "utf16_be"),
                            TextEncoding(name: "Unicode (UTF-16LE)", id: "utf16_le")]

    @Published
    var lineEndingsList = [LineEndings(name: "macOS / Unix (LF)", id: "macos"),
                           LineEndings(name: "Classic macOS (CR)", id: "classic"),
                           LineEndings(name: "Windows (CRLF)", id: "windows")]

    @Published
    var indentUsingList = [IndentUsing(name: "Spaces", id: "spaces"),
                           IndentUsing(name: "Tabs", id: "tabs")]

    public init(workspaceURL: URL, fileURL: String) {
        self.workspaceURL = workspaceURL
        self.fileURL = fileURL
        self.fileName = (fileURL as NSString).lastPathComponent
    }
}

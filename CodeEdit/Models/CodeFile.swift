//
//  CodeFile.swift
//  CodeEdit
//
//  Created by Rehatbir Singh on 12/03/2022.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct CodeFile: FileDocument {
    
    static var readableContentTypes = [UTType.sourceCode]
    var text = ""
    
    init(initialText: String = "") {
        self.text = initialText
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
    
}


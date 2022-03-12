//
//  Workspace.swift
//  CodeEdit
//
//  Created by Rehatbir Singh on 12/03/2022.
//

import Foundation

struct Workspace {
    
    var directoryURL: URL
    var directoryContents: [URL]
    
    init(url: URL) throws {
        directoryURL = url
        directoryContents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
    }
    
}

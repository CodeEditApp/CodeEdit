//
//  ProjectPath.swift
//  CodeEditUITests
//
//  Created by Khan Winter on 7/10/24.
//

import Foundation

func projectPath() -> String {
    return String(
        URL(fileURLWithPath: #filePath)
            .pathComponents
            .prefix(while: { $0 != "CodeEditUITests" })
            .joined(separator: "/")
            .dropFirst()
    )
}

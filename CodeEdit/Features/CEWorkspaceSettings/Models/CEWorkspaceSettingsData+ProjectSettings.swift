//
//  ProjectCEWorkspaceSettings.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import SwiftUI

class ProjectSettings: ObservableObject, Codable {
    var projectName: String = ""

    init() {}

    /// Explicit decoder init for setting default values when key is not present in `JSON`
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.projectName = try container.decodeIfPresent(String.self, forKey: .projectName) ?? ""
    }

    func isEmpty() -> Bool {
        projectName == ""
    }
}

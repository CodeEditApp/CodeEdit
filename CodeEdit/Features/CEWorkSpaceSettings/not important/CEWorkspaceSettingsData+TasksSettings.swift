//
//  CEWorkspaceSettingsData+TasksSettings.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import Foundation
import Collections

struct TasksSettings: Codable, Hashable {
    /// The tasks functionality behavior of the app
    var enabled: Bool = true

    init() {}
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.items = try container.decodeIfPresent([CETask].self, forKey: .items) ?? []
//        self.enabled = try container.decodeIfPresent(Bool.self, forKey: .enabled) ?? true
//    }
//
//    func isEmpty() -> Bool {
//        items.isEmpty && enabled == true
//    }
}


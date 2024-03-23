//
//  RecentProject.swift
//  CodeEditV2
//
//  Created by Abe Malla on 3/19/24.
//

import Foundation

import Foundation

struct RecentProject: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var path: String
    var lastOpened: Date
}

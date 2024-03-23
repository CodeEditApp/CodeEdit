//
//  ProjectManager.swift
//  CodeEditV2
//
//  Created by Abe Malla on 3/19/24.
//

import Foundation

class ProjectManager {
    static let shared = ProjectManager()
    
    func getRecentProjects() -> [RecentProject] {
        // TODO: Placeholder implementation
        return [
            RecentProject(name: "Project 1", path: "/path/to/project1", lastOpened: Date()),
            RecentProject(name: "Project 2", path: "/path/to/project2", lastOpened: Date().addingTimeInterval(-86400))
        ]
    }
}

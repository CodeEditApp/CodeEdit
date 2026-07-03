//
//  ProjectNavigatorViewModel.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 03/07/2026.
//

import Foundation

/// UI state for the Project Navigator: its filter text and sort/filter toggles.
/// Extracted from `Workspace` so navigator views don't depend on the whole workspace hub.
@MainActor
final class ProjectNavigatorViewModel: ObservableObject {
    @Published var navigatorFilter: String = ""
    @Published var sortFoldersOnTop: Bool = true
    @Published var sourceControlFilter: Bool = false

    init() {}
}

//
//  NavigatorContributions.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/08/26.
//

import CodeEditUI
import SwiftUI

/// The project navigator is shell chrome: it has no owning package and stays app-side permanently.
struct ProjectNavigatorContribution: WorkspacePanelContribution {
    let id = "project"
    let title = "Project"
    let systemImage = "folder"
    var content: AnyView { AnyView(ProjectNavigatorView()) }
}

struct SourceControlNavigatorContribution: WorkspacePanelContribution {
    let id = "sourceControl"
    let title = "Source Control"
    let systemImage = "vault"
    var content: AnyView { AnyView(SourceControlNavigatorView()) }
}

struct FindNavigatorContribution: WorkspacePanelContribution {
    let id = "search"
    let title = "Search"
    let systemImage = "magnifyingglass"
    var content: AnyView { AnyView(FindNavigatorTab()) }
}

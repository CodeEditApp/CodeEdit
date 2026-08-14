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
    let id = PanelTabID.project
    let title = "Project"
    let systemImage = "folder"
    var content: AnyView { AnyView(ProjectNavigatorView()) }
}

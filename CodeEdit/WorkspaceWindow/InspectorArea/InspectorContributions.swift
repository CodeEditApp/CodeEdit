//
//  InspectorContributions.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/08/26.
//

import CodeEditUI
import SwiftUI

struct FileInspectorContribution: WorkspacePanelContribution {
    let id = PanelTabID.file
    let title = "File Inspector"
    let systemImage = "doc"
    var content: AnyView { AnyView(FileInspectorView()) }
}

struct InternalDevelopmentInspectorContribution: WorkspacePanelContribution {
    let id = PanelTabID.internalDevelopment
    let title = "Internal Development"
    let systemImage = "hammer"
    var content: AnyView { AnyView(InternalDevelopmentInspectorView()) }
}

//
//  InspectorAreaViewModel.swift
//  CodeEdit
//
//  Created by Abe Malla on 9/23/23.
//

import Foundation
import CodeEditUI

class InspectorAreaViewModel: ObservableObject {
    @Published var selectedTabID: String? = PanelTabID.file
    /// The tab bar items in the Inspector
    @Published var tabItems: [any WorkspacePanelContribution] = []
}

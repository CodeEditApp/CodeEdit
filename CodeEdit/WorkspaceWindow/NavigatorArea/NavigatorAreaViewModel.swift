//
//  NavigatorAreaViewModel.swift
//  CodeEdit
//
//  Created by Abe Malla on 7/23/23.
//

import Foundation
import CodeEditUI

class NavigatorAreaViewModel: ObservableObject {
    @Published var selectedTabID: String? = "project"
    /// The tab bar items in the Navigator
    @Published var tabItems: [any WorkspacePanelContribution] = []
}

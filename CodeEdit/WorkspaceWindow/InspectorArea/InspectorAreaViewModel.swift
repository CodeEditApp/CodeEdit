//
//  InspectorAreaViewModel.swift
//  CodeEdit
//
//  Created by Abe Malla on 9/23/23.
//

import Foundation

class InspectorAreaViewModel: ObservableObject {
    @Published var selectedTab: InspectorTab? = .file
    /// The tab bar items in the Inspector
    @Published var tabItems: [InspectorTab] = []

    func setInspectorTab(tab newTab: InspectorTab) {
        selectedTab = newTab
    }
}

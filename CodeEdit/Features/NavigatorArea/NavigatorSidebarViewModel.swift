//
//  NavigatorSidebarViewModel.swift
//  CodeEdit
//
//  Created by Abe Malla on 7/23/23.
//

import Foundation

class NavigatorSidebarViewModel: ObservableObject {
    @Published var selectedTab: NavigatorTab? = .project
    var items: [NavigatorTab] = []

    func setNavigatorTab(tab newTab: NavigatorTab) {
        selectedTab = newTab
    }
}

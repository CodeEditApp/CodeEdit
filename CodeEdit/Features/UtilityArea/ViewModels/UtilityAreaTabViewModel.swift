//
//  UtilityAreaTabViewModel.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/31/23.
//

import SwiftUI

class UtilityAreaTabViewModel: ObservableObject {
    @Published var leadingSidebarIsCollapsed: Bool = false

    @Published var trailingSidebarIsCollapsed: Bool = false

    @Published var hasLeadingSidebar: Bool = false

    @Published var hasTrailingSidebar: Bool = false

    public static let shared: UtilityAreaTabViewModel = .init()
}

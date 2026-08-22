//
//  UtilityAreaView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

struct UtilityAreaView: View {
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    var body: some View {
        WorkspacePanelView(
            viewModel: utilityAreaViewModel,
            selectedTabID: $utilityAreaViewModel.selectedTabID,
            tabItems: $utilityAreaViewModel.tabItems,
            sidebarPosition: .side,
            darkDivider: true,
            padSideItemVertically: true
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Utility Area")
        .accessibilityIdentifier("UtilityArea")
    }
}

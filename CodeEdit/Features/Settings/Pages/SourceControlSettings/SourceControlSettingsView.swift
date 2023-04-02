//
//  SourceControlSettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

struct SourceControlSettingsView: View {
    var body: some View {
        SegmentedControl($selectedSection, options: ["General", "Git"])
        if selectedSection == 0 {
            SourceControlGeneralView()
        }
        if selectedSection == 1 {
            SourceControlGitView()
        }
    }

    @State
    private var selectedSection: Int = 0
}

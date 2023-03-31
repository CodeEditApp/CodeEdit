//
//  SourceControlPreferencesView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct SourceControlPreferencesView: View {

    // MARK: - View

    var body: some View {
        sourceControlSelector
            .frame(width: 715)
    }

    @State
    private var selectedSection: Int = 0
}

extension SourceControlPreferencesView {

    // MARK: - Preference Views

    private var sourceControlSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 1) {
                PreferencesToolbar {
                    SegmentedControl($selectedSection, options: ["General", "Git"])
                }
                if selectedSection == 0 {
                    SourceControlGeneralView(isChecked: true, branchName: "main")
                }
                if selectedSection == 1 {
                    SourceControlGitView()
                }
            }
            .padding(1)
            .background(Rectangle().foregroundColor(Color(NSColor.separatorColor)))
            .frame(width: 872)
            .padding()
        }
    }
}

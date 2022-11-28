//
//  PreferenceSourceControlView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct PreferenceSourceControlView: View {
    @State
    private var selectedSection: Int = 0

    var body: some View {
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

struct PreferenceSourceControlView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceSourceControlView()
    }
}

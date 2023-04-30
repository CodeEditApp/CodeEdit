//
//  SourceControlSettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

struct SourceControlSettingsView: View {
    @State var selectedTab: String = "general"

    var body: some View {
        Group {
            switch selectedTab {
            case "general":
                SourceControlGeneralView()
            case "git":
                SourceControlGitView()
            default:
                SourceControlGeneralView()
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("General").tag("general")
                Text("Git").tag("git")
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

        }
    }
}

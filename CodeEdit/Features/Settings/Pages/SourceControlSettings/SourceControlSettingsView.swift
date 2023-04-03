//
//  SourceControlSettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

struct SourceControlSettingsView: View {
    @State var selection: SourceControlSettingsTab = .general

    enum SourceControlSettingsTab: String, CaseIterable {
        case general = "General"
        case git = "Git"
    }

//    var body: some View {
//        VStack(spacing: 0) {
//            Picker("", selection: $selection) {
//                ForEach(SourceControlSettingsTab.allCases, id: \.self) { tab in
//                    Text(tab.rawValue)
//                        .tag(tab)
//                }
//            }
//            .pickerStyle(.segmented)
//            .padding(.leading, 12)
//            .padding(.trailing, 20)
//            .padding(.top, 20)
//            switch selection {
//            case .general:
//                SourceControlGeneralView()
//            case .git:
//                SourceControlGitView()
//            }
//        }
//    }

    var body: some View {
        Form {
            SourceControlGeneralView()
            SourceControlGitView()
        }
        .formStyle(.grouped)
    }
}

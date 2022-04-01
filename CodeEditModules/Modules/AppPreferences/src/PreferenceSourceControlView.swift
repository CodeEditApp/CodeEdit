//
//  PreferenceSourceControlView.swift
//  
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

public struct PreferenceSourceControlView: View {

    public init() {}

    public var body: some View {
        TabView {
            SourceControlGeneralView(isChecked: true, branchName: "main").tabItem {
                Text("General")
            }
            SourceControlGitView(authorName: "Nanashi Li", isChecked: false).tabItem {
                Text("Git")
            }
        }
        .frame(width: 844)
        .padding(20)
    }
}

struct PreferenceSourceControlView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceSourceControlView()
    }
}

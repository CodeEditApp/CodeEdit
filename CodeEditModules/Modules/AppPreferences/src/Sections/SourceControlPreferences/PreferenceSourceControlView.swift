//
//  PreferenceSourceControlView.swift
//  
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI
import CodeEditUI

public struct PreferenceSourceControlView: View {

    @ObservedObject
    private var sourceControlModel: SourceControlModel = .shared

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sourceControlContent
            .padding(1)
            .background(Rectangle().foregroundColor(Color(NSColor.separatorColor)))
            .frame(height: 468)
            .background(Rectangle().foregroundColor(Color(NSColor.controlBackgroundColor)))
        }
    }

    private var sourceControlContent: some View {
        VStack(spacing: 1) {
            let options = [
                "General",
                "Git"
            ]
            toolbar {
                SegmentedControl($sourceControlModel.selectedTab, options: options)
            }
            switch sourceControlModel.selectedTab {
            case 1:
                SourceControlGitView()
            default:
                SourceControlGeneralView(isChecked: true, branchName: "main")
            }
        }
    }

    private func toolbar<T: View>(
        height: Double = 27,
        bgColor: Color = Color(NSColor.controlBackgroundColor),
        @ViewBuilder content: @escaping () -> T
    ) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(bgColor)
            HStack {
                content()
                    .padding(.horizontal, 8)
            }
        }
        .frame(height: height)
    }
}

struct PreferenceSourceControlView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceSourceControlView()
    }
}

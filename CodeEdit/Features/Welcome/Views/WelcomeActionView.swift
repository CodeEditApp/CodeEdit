//
//  WelcomeActionView.swift
//  CodeEditModules/WelcomeModule
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI

struct WelcomeActionView: View {
    var iconName: String
    var title: String
    var subtitle: String

    init(iconName: String, title: String, subtitle: String) {
        self.iconName = iconName
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.accentColor)
                .font(.system(size: 30, weight: .light))
                .frame(width: 24)
            VStack(alignment: .leading) {
                Text(title)
                    .bold()
                    .font(.system(size: 13))
                Text(subtitle)
                    .font(.system(size: 12))
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

struct WelcomeActionView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeActionView(
            iconName: "plus.square",
            title: "Create a new file",
            subtitle: "Create a new file"
        )
    }
}

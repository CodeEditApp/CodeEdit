//
//  WelcomeActionView.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI

public struct WelcomeActionView: View {
    var iconName: String
    var title: LocalizedStringKey
    var subtitle: LocalizedStringKey
    
    public init(iconName: String, title: LocalizedStringKey, subtitle: LocalizedStringKey) {
        self.iconName = iconName
        self.title = title
        self.subtitle = subtitle
    }
    
    public var body: some View {
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

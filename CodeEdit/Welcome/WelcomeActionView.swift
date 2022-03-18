//
//  WelcomeActionView.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI

struct WelcomeActionView: View {
    var iconName: String
    var title: String
    var subtitle: String
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconName)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.primary)
                .font(.system(size: 24, weight: .light))
                .frame(width: 24)
            VStack(alignment: .leading) {
                Text(title)
                    .bold()
                    .font(.system(size: 16))
                Text(subtitle)
                    .font(.system(size: 14))
            }
            Spacer()
        }
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

//
//  ThemeSettingsView.swift
//  CodeEdit
//
//  Created by 朱浩宇 on 2022/3/22.
//

import SwiftUI

struct ThemeSettingsView: View {

    let gridRule = [GridItem](repeating: GridItem(.flexible(), alignment: .top), count: 4)

    var body: some View {
        LazyVGrid(columns: gridRule) {
            ForEach(Theme.all) { themeItem in
                VStack {
                    VStack {
                        themeItem.image
                            .resizable()
                            .frame(width: 55 * 2, height: 35 * 2)
                            .scaledToFit()
                            .border(Color(hexadecimal: "4D4D4D"), width: 1.5)
                            .cornerRadius(3)

                        Text(themeItem.name)
                    }
                    .padding()
                }
                .padding()
            }
        }
        .frame(width: 750)
        .padding()
    }
}

struct ThemeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeSettingsView()
    }
}

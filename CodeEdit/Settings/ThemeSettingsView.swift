//
//  ThemeSettingsView.swift
//  CodeEdit
//
//  Created by 朱浩宇 on 2022/3/23.
//

import SwiftUI

struct ThemeSettingsView: View {
    let gridRule = [GridItem](repeating: GridItem(.flexible(), alignment: .top), count: 5)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridRule) {
                ForEach(Themes.all) { themeItem in
                    VStack {
                        VStack {
                            themeItem.image
                                .resizable()
                                .frame(width: 116, height: 62)
                                .scaledToFit()
                                .border(Color.secondary, width: 1.5)
                                .cornerRadius(3)

                            Text(themeItem.name)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                    .padding()
                }
            }
        }
        .frame(width: 820, height: 450)
        .padding()
    }
}

struct ThemeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeSettingsView()
    }
}

//
//  PreviewThemeView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

struct PreviewThemeView: View {
    @StateObject
    private var themeModel: ThemeModel = .shared

    var body: some View {
        ZStack(alignment: .topLeading) {
            EffectView(.contentBackground)
            if themeModel.selectedTheme == nil {
                Text("Select a Theme")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                Text("Preview is not yet implemented")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }
}

private struct PreviewThemeView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewThemeView()
    }
}

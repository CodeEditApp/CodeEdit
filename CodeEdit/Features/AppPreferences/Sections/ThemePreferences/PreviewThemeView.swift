//
//  PreviewThemeView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

/// A view that implements the `Preview theme` preference section
struct PreviewThemeView: View {
    // MARK: - View
    var body: some View {
        previewTheme
    }
    
    @StateObject
    private var themeModel: ThemeModel = .shared
}

private extension PreviewThemeView {
    // MARK: - Sections

    private var previewTheme: some View {
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

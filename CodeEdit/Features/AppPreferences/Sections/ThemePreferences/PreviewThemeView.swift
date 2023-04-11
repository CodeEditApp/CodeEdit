//
//  PreviewThemeView.swift
//  CodeEditModules/Settings
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
                selectTheme
            } else {
                previewNotYetImplemented
            }
        }
    }

    // MARK: - Preferences Views

    private var selectTheme: some View {
        Text("Select a Theme")
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var previewNotYetImplemented: some View {
        Text("Preview is not yet implemented")
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

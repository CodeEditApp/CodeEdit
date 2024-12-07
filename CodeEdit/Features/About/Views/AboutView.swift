//
//  AboutView.swift
//  CodeEditModules/About
//
//  Created by Andrei Vidrasco on 02.04.2022
//

import SwiftUI

enum AboutMode: String, CaseIterable {
    case about
    case acknowledgements
    case contributors
}

public struct AboutView: View {
    @Environment(\.openURL)
    private var openURL
    @Environment(\.colorScheme)
    private var colorScheme
    @Environment(\.dismiss)
    private var dismiss

    @State var aboutMode: AboutMode = .about

    @Namespace var animator

    public var body: some View {
        ZStack(alignment: .top) {
            switch aboutMode {
            case .about:
                AboutDefaultView(aboutMode: $aboutMode, namespace: animator)
            case .acknowledgements:
                AcknowledgementsView(aboutMode: $aboutMode, namespace: animator)
            case .contributors:
                ContributorsView(aboutMode: $aboutMode, namespace: animator)
            }
        }
        .animation(.smooth, value: aboutMode)
        .ignoresSafeArea()
        .frame(width: 280, height: 400 - 28)
        .fixedSize()
        // hack required to get buttons appearing correctly in light appearance
        // if anyone knows of a better way to do this feel free to refactor
        .background(.regularMaterial.opacity(0))
        .background(EffectView(.popover, blendingMode: .behindWindow).ignoresSafeArea())
        .background {
            Button("") {
                dismiss()
            }
            .keyboardShortcut(.escape, modifiers: [])
            .hidden()
        }
        .task {
            if let window = NSApp.findWindow(.about) {
                window.styleMask = [.closable, .fullSizeContentView, .titled, .nonactivatingPanel]
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
                window.backgroundColor = .gray.withAlphaComponent(0.15)
                window.isMovableByWindowBackground = true
            }
        }
    }
}

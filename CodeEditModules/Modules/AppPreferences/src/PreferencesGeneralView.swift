//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI
import Preferences

public struct PreferencesGeneralView: View {

    @AppStorage(Appearances.storageKey)
    private var appearance: Appearances = .default

    @AppStorage(ReopenBehavior.storageKey)
    private var reopenBehavior: ReopenBehavior = .default

    @AppStorage(FileIconStyle.storageKey)
    private var fileIconStyle: FileIconStyle = .default

    public init() {}

    public var body: some View {
        Form {
            Picker("Appearance:", selection: $appearance) {
                Text("System")
                    .tag(Appearances.system)
                Divider()
                Text("Light")
                    .tag(Appearances.light)
                Text("Dark")
                    .tag(Appearances.dark)
            }
            .onChange(of: appearance) { tag in
                tag.applyAppearance()
            }
            .fixedSize()

            Picker("File Icon Style:", selection: $fileIconStyle) {
                Text("Color")
                    .tag(FileIconStyle.color)
                Text("Monochrome")
                    .tag(FileIconStyle.monochrome)
            }
            .pickerStyle(.radioGroup)

            Picker("Reopen Behavior:", selection: $reopenBehavior) {
                Text("Welcome Screen")
                    .tag(ReopenBehavior.welcome)
                Divider()
                Text("Open Panel")
                    .tag(ReopenBehavior.openPanel)
                Text("New Document")
                    .tag(ReopenBehavior.newDocument)
            }
            .fixedSize()
        }
        .frame(width: 844)
        .padding(30)
    }
}

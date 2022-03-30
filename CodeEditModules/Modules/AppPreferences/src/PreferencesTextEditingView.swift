//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI
import CodeFile

public struct PreferencesTextEditingView: View {

    @AppStorage(EditorTabWidth.storageKey)
    var defaultTabWidth: Int = EditorTabWidth.default

    public init() {}

    public var body: some View {
        Form {
            HStack {
                Stepper("Default Tab Width:", value: $defaultTabWidth, in: 2...8)
                Text(String(defaultTabWidth))
            }
        }
        .frame(width: 844)
        .padding(30)
    }
}

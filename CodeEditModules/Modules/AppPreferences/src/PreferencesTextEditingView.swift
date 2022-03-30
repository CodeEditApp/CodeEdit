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

    var tabStringBinding: Binding<String> {
        Binding<String> {
            String(defaultTabWidth)
        } set: {
            defaultTabWidth = Int($0) ?? defaultTabWidth
        }

    }

    public init() {}

    public var body: some View {
        Form {
            HStack(spacing: 5) {
                Stepper(value: $defaultTabWidth, in: 2...8, step: 1) {
                    TextField("", text: tabStringBinding)
                        .frame(width: 50)
                        .multilineTextAlignment(.trailing)
                }

                Text("spaces")
            }
            .formLabel(Text("Tab Width:"), spacing: 0)
        }
        .frame(width: 844)
        .padding(30)
    }
}

//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI
import Preferences

@available(macOS 12, *)
public struct PreferencesThemeView: View {

    public init() {}

    public var body: some View {
        Preferences.Container(contentWidth: 844) {
            Preferences.Section(title: "") {
                CustomPicker()
            }
            Preferences.Section(title: "") {
                Toggle("Use theme background", isOn: .constant(true))
                Toggle("Automatically change theme based on system appearance", isOn: .constant(true))
            }
        }
    }

    struct CustomPicker: View {
        @State private var selection: Int = 0

        var body: some View {
            HStack {
                Button { selection = 0 } label: {
                    Text("Dark Mode")
                        .foregroundColor(.white)
                }
                .padding(4)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(selection == 0 ? .accentColor : .clear)
                }
                Button { selection = 1 } label: {
                    Text("Light Mode")
                }
                .padding(4)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(selection == 1 ? .accentColor : .clear)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

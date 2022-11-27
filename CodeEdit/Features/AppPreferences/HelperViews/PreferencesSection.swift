//
//  PreferencesSection.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 03.04.22.
//

import SwiftUI

/// A view that wraps multiple ``PreferencesSection`` views and aligns them correctly.
struct PreferencesContent<Content: View>: View {

    private let width: Double
    private let content: Content

    init(width: Double = 844, @ViewBuilder content: () -> Content) {
        self.width = width
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .frame(width: width)
        .padding(30)
    }
}

/// A view that wraps controls and more and adds a right aligned label.
struct PreferencesSection<Content: View>: View {

    private let title: String
    private let width: Double
    private let hideLabels: Bool
    private let content: Content
    private let align: VerticalAlignment

    init(
        _ title: String,
        width: Double = 300,
        hideLabels: Bool = true,
        align: VerticalAlignment = .firstTextBaseline,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.width = width
        self.hideLabels = hideLabels
        self.align = align
        self.content = content()
    }

    var body: some View {
        HStack(alignment: align) {
            /// We keep the ":" since it's being used by all preference views.
            Text("\(title):")
                .frame(width: width, alignment: .trailing)
            if hideLabels {
                VStack(alignment: .leading) {
                    content
                        .labelsHidden()
                        .fixedSize()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: 20)
                }
            } else {
                VStack(alignment: .leading) {
                    content
                        .fixedSize()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: 20)
                }
            }
        }
    }
}

struct PreferencesSection_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesSection("Title") {
            Picker("Test", selection: .constant(true)) {
                Text("Hi")
                    .tag(true)
            }
            Text("Whats up?")
        }
    }
}

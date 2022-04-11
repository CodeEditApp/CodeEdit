//
//  PreferencesSection.swift
//  
//
//  Created by Lukas Pistrol on 03.04.22.
//

import SwiftUI

/// A view that wraps multiple ``PreferencesSection`` views and aligns them correctly.
public struct PreferencesContent<Content: View>: View {

    private var width: Double
    private var content: Content

    public init(width: Double = 844, @ViewBuilder content: () -> Content) {
        self.width = width
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .frame(width: width)
        .padding(30)
    }
}

/// A view that wraps controls and more and adds a right aligned label.
public struct PreferencesSection<Content: View>: View {

    private var title: String
    private var width: Double
    private var hideLabels: Bool
    private var content: Content

    public init(_ title: String, width: Double = 300, hideLabels: Bool = false, @ViewBuilder content: () -> Content) {
        self.title = title
        self.width = width
        self.hideLabels = hideLabels
        self.content = content()
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
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

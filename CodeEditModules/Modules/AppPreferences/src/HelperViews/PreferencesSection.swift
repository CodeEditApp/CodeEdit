//
//  PreferencesSection.swift
//  
//
//  Created by Lukas Pistrol on 03.04.22.
//

import SwiftUI

internal struct PreferencesContent<Content: View>: View {

    private var width: Double
    private var content: Content

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

internal struct PreferencesSection<Content: View>: View {

    private var title: String
    private var width: Double
    private var content: Content

    init(_ title: String, width: Double = 300, @ViewBuilder content: () -> Content) {
        self.title = title
        self.width = width
        self.content = content()
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(title):")
                .frame(width: width, alignment: .trailing)
            VStack(alignment: .leading) {
                content
                    .labelsHidden()
                    .fixedSize()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 20)
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

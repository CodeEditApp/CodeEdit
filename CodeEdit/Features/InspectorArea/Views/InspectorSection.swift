//
//  InspectorSection.swift
//  CodeEdit
//
//  Created by Austin Condiff on 1/12/23.
//

import SwiftUI

struct InspectorSection<Content: View>: View {
    var label: String
    let content: Content

    init(_ label: String, @ViewBuilder _ content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text(label)
                .foregroundColor(.secondary)
                .fontWeight(.bold)
                .font(.system(size: 12))
                .padding(.leading, -1)
            VStack(alignment: .trailing, spacing: 5) {
                content
                Divider()
            }
        }
    }
}

struct InspectorSection_Previews: PreviewProvider {
    static var previews: some View {
        InspectorSection("Section Label") {
            Text("Preview")
        }
    }
}

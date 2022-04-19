//
//  InspectorSidebarToolbar.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/21/22.
//

import SwiftUI

struct InspectorSidebarToolbarTop: View {
    @Binding
    var selection: Int

    var body: some View {
        HStack(spacing: 10) {
            icon(systemImage: "doc", title: "File Inspector", id: 0)
            icon(systemImage: "clock", title: "History Inspector", id: 1)
            icon(systemImage: "questionmark.circle", title: "Quick Help Inspector", id: 2)
        }
        .frame(height: 29, alignment: .center)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) {
            Divider()
        }
        .overlay(alignment: .bottom) {
            Divider()
        }
        .background(Rectangle()
            .foregroundColor(Color("InspectorBackgroundColor")))
    }

    func icon(systemImage: String, title: String, id: Int) -> some View {
        Button {
            selection = id
        } label: {
            Image(systemName: systemImage)
                .help(title)
                .symbolVariant(id == selection ? .fill : .none)
                .foregroundColor(id == selection ? .accentColor : .secondary)
                .frame(width: 16, alignment: .center)
        }
        .buttonStyle(.plain)
    }
}

struct InspectorSidebarToolbar_Previews: PreviewProvider {
    static var previews: some View {
        InspectorSidebarToolbarTop(selection: .constant(0))
    }
}

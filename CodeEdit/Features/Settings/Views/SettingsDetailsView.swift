//
//  SettingsDetailsView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/8/23.
//

import SwiftUI

struct SettingsDetailsView<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var model: SettingsModel

    let title: String

    @ViewBuilder
    var content: Content

    var body: some View {
        content
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    print(self.presentationMode.wrappedValue)
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
                Text(title)
            }
        }
        .hideSidebarToggle()
        .task {
            let window = NSApp.windows.first { $0.identifier?.rawValue == "settings" }!
            window.title = title
        }
        .onAppear {
            model.showingDetails = true
        }
    }
}

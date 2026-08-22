//
//  View+NavigationBarBackButtonVisible.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/8/23.
//

import SwiftUI

struct NavigationBarBackButtonVisible: ViewModifier {
    @Environment(\.presentationMode)
    var presentationMode
    @EnvironmentObject var model: SettingsViewModel

    func body(content: Content) -> some View {
        content
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 23)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            model.backButtonVisible = true
        }
        .onDisappear {
            model.backButtonVisible = false
        }
    }
}

extension View {
    func navigationBarBackButtonVisible() -> some View {
        modifier(NavigationBarBackButtonVisible())
    }
}

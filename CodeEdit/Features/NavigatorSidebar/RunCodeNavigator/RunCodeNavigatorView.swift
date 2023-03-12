//
//  RunCodeNavigatorView.swift
//  CodeEdit
//
//  Created by Raymondo Russo on 12/03/23.
//

import SwiftUI

struct RunCodeNavigatorView: View {

    @EnvironmentObject
    private var workspace: WorkspaceDocument

    var body: some View {
        Button {
            print("Edit button was tapped")
        } label: {
            Image(systemName: "pencil")
        }
        .frame(maxWidth: .infinity)
        .frame(height: 27)
        .padding(.horizontal, 8)
        .padding(.bottom, 2)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}

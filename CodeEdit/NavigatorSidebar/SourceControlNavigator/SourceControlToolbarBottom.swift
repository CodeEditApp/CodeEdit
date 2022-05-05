//
//  SourceControlToolbarBottom.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/05.
//
import SwiftUI

struct SourceControlToolbarBottom: View {
    var body: some View {
        HStack(spacing: 0) {
            addNewFileButton
            SourceControlSearchToolbar()
        }
        .frame(height: 29, alignment: .center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    private var addNewFileButton: some View {
        Menu {
            Button("Discard Changes...") {}
                .disabled(true)
            Button("Stash Changes...") {}
                .disabled(true)
            Button("Commit...") {}
                .disabled(true)
            Button("Create Pull Request...") {}
                .disabled(true)
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(maxWidth: 30)
    }
}

struct SourceControlToolbarBottom_Previews: PreviewProvider {
    static var previews: some View {
        SourceControlToolbarBottom()
    }
}

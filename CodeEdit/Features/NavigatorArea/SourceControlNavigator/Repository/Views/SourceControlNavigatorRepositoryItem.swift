//
//  SourceControlNavigatorRepositoriesItem.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/29/23.
//

import SwiftUI

struct SourceControlNavigatorRepositoryItem: View {
    let item: RepoOutlineGroupItem

    @Environment(\.controlActiveState)
    var controlActiveState

    var body: some View {
        if item.systemImage != nil || item.symbolImage != nil {
            Label(title: {
                Text(item.label)
                    .lineLimit(1)
                    .truncationMode(.middle)
                if let description = item.description {
                    Text(description)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                        .font(.system(size: 11))
                }
            }, icon: {
                if item.symbolImage != nil {
                    Image(symbol: item.symbolImage ?? "")
                        .opacity(controlActiveState == .inactive ? 0.5 : 1)
                        .foregroundStyle(item.imageColor ?? .accentColor)
                } else {
                    Image(systemName: item.systemImage ?? "")
                        .opacity(controlActiveState == .inactive ? 0.5 : 1)
                        .foregroundStyle(item.imageColor ?? .accentColor)
                }
            })
            .padding(.leading, 1)
            .padding(.vertical, -1)
        } else {
            Text(item.label)
                .padding(.leading, 2)
        }
    }
}

//
//  WorkspaceMenuItemView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 24.06.24.
//

import SwiftUI

struct WorkspaceMenuItemView: View {
    var workspaceFileManager: CEWorkspaceFileManager?
    var item: CEWorkspaceFile?

    var body: some View {
        HStack(spacing: 5) {
            if workspaceFileManager?.workspaceItem.fileName() == item?.name {
                Image(systemName: "checkmark")
                    .fontWeight(.bold)
                    .imageScale(.small)
                    .frame(width: 10)
            } else {
                Spacer()
                    .frame(width: 10)
            }
            Image(systemName: "folder.badge.gearshape")
                .imageScale(.medium)
            Text(item?.name ?? "")
            Spacer()
        }
        .dropdownItemStyle()
        .onTapGesture { } // add accessibility action when this is filled in
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .accessibilityElement()
        .accessibilityLabel(item?.name ?? "")
    }
}

#Preview {
    WorkspaceMenuItemView()
}

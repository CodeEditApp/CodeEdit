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
        HStack {
            if workspaceFileManager?.workspaceItem.fileName() == item?.name {
                Image(systemName: "checkmark")
                    .imageScale(.small)
                    .frame(width: 10)
            } else {
                Spacer()
                    .frame(width: 18)
            }
            Image(systemName: "folder.badge.gearshape")
                .imageScale(.medium)
            Text(item?.name ?? "")
            Spacer()
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .modifier(DropdownMenuItemStyleModifier())
        .onTapGesture { }
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

#Preview {
    WorkspaceMenuItemView()
}

//
//  SchemeDropDownView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 24.06.24.
//

import SwiftUI

struct SchemeDropDownView: View {
    @Environment(\.colorScheme)
    private var colorScheme

    @State var isSchemePopOverPresented: Bool = false
    @State private var isHoveringScheme: Bool = false

    @ObservedObject var workspaceSettingsManager: CEWorkspaceSettings
    var workspaceFileManager: CEWorkspaceFileManager?

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "folder.badge.gearshape")
                .imageScale(.medium)

            Group {
                if workspaceSettingsManager.settings.project.projectName.isEmpty {
                    Text(workspaceFileManager?.workspaceItem.fileName() ?? "No Project found")
                } else {
                    Text(workspaceSettingsManager.settings.project.projectName)
                }
            }.font(.subheadline)
        }
        .font(.caption)
        .padding(.trailing, 11.5)
        .padding(.horizontal, 2.5)
        .padding(.vertical, 2.5)
        .background {
            Color(nsColor: colorScheme == .dark ? .white : .black)
                .opacity(isHoveringScheme || isSchemePopOverPresented ? 0.05 : 0)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 4, height: 4)))
            HStack {
                Spacer()
                if isHoveringScheme || isSchemePopOverPresented {
                    chevronDown
                        .padding(.trailing, 2)
                } else {
                    chevron
                        .padding(.trailing, 4)
                }
            }
        }
        .onHover(perform: { hovering in
            self.isHoveringScheme = hovering
        })
        .popover(isPresented: $isSchemePopOverPresented, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                WorkspaceMenuItemView(
                    workspaceFileManager: workspaceFileManager,
                    item: workspaceFileManager?.workspaceItem
                )

                Divider()
                    .padding(.vertical, 5)
                Group {
                    OptionMenuItemView(label: "Add Folder..") {
                        // TODO: Implment Add Folder
                        print("NOT IMPLMENTED")
                    }
                    OptionMenuItemView(label: "Workspace Settings...") {
                        NSApp.sendAction(
                            #selector(CodeEditWindowController.openWorkspaceSettings(_:)), to: nil, from: nil
                        )
                    }
                }
            }
            .padding(5)
        }.onTapGesture {
            self.isSchemePopOverPresented.toggle()
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.compact.right")
            .font(.system(size: 9, weight: .medium, design: .default))
            .foregroundStyle(.secondary)
            .scaleEffect(x: 1.30, y: 1.0, anchor: .center)
            .imageScale(.large)
    }

    private var chevronDown: some View {
        VStack(spacing: 1) {
            Image(systemName: "chevron.down")
        }
        .font(.system(size: 8, weight: .semibold, design: .default))
        .padding(.top, 0.5)
    }
}

// #Preview {
//    SchemeDropDownMenuView()
// }

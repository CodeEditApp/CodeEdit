//
//  GitChangedFileListView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI
import CodeEditSettings
import CodeEditCore
import CodeEditUI

/// A view to display a changed file's information in a list view. Optionally displays the staged status.
struct GitChangedFileListView: View {
    @SettingsValue(GeneralSettings.self, \.fileIconStyle)
    private var fileIconStyle
    @EnvironmentObject private var sourceControlManager: SourceControlManager

    @Binding private var changedFile: GitChangedFile

    @State private var staged: Bool
    private let showStaged: Bool

    init(changedFile: Binding<GitChangedFile>, showStaged: Bool = true) {
        self._changedFile = changedFile
        self.showStaged = showStaged
        self._staged = State(initialValue: changedFile.wrappedValue.isStaged)
    }

    var body: some View {
        HStack(spacing: 6) {
            if showStaged {
                Toggle("", isOn: $staged)
                    .labelsHidden()
                    .onChange(of: staged) { _, newStaged in
                        Task {
                            if changedFile.isStaged != newStaged {
                                if newStaged {
                                    try await sourceControlManager.add([changedFile.fileURL])
                                } else {
                                    try await sourceControlManager.reset([changedFile.fileURL])
                                }
                            }
                        }
                    }
            }

            GitChangedFileLabel(file: changedFile)
            Spacer()
            Text(changedFile.anyStatus().description)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
                .frame(minWidth: 10, alignment: .center)
        }
        .listItemTint(listItemTint)
        .help(changedFile.fileURL.relativePath)
        .onChange(of: changedFile.isStaged) { _, newStaged in
            staged = newStaged
        }
    }

    private var listItemTint: Color {
        switch fileIconStyle {
        case .color:
            return FileIcon.spec(for: changedFile.fileURL).color
        case .monochrome:
            return Color("CoolGray")
        }
    }
}

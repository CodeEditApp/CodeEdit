//
//  IgnoredFilesListView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/1/24.
//

import SwiftUI

struct IgnoredFilesListView: View {
    @ObservedObject private var model = IgnorePatternModel()

    var body: some View {
        GlobPatternList(
            patterns: $model.patterns,
            selection: $model.selection,
            addPattern: model.addPattern,
            removePatterns: model.removePatterns,
            emptyMessage: "No ignored files"
        )
    }
}

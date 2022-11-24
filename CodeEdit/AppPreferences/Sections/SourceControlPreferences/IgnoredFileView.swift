//
//  IgnoredFileView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanashi Li on 2022/04/13.
//

import SwiftUI

struct IgnoredFileView: View {
    @Binding
    var ignoredFile: IgnoredFiles

    var body: some View {
        Text(ignoredFile.name)
    }
}

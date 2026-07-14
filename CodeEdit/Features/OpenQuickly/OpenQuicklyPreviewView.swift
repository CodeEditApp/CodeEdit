//
//  OpenQuicklyPreviewView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI
import CodeEditCore

struct OpenQuicklyPreviewView: View {
    let item: CEWorkspaceFile

    @Environment(\.filePreview) private var filePreview

    var body: some View {
        filePreview(item)
    }
}

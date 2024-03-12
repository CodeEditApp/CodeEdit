//
//  SplitViewData.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import SwiftUI

final class SplitViewData: ObservableObject {
    @Published var editorLayouts: [EditorLayout]

    var axis: Axis

    init(_ axis: Axis, editorLayouts: [EditorLayout] = []) {
        self.editorLayouts = editorLayouts
        self.axis = axis

        editorLayouts.forEach {
            if case .one(let editor) = $0 {
                editor.parent = self
            }
        }
    }

    /// Splits the editor at a certain index into two separate editors.
    /// - Parameters:
    ///   - direction: direction in which the editor will be split.
    ///   If the direction is the same as the ancestor direction,
    ///   the editor is added to the ancestor instead of creating a new split container.
    ///   - index: index where the divider will be added.
    ///   - editor: new editor class that will be used for the editor.
    func split(_ direction: Edge, at index: Int, new editor: Editor) {
        editor.parent = self
        switch (axis, direction) {
        case (.horizontal, .trailing), (.vertical, .bottom):
            editorLayouts.insert(.one(editor), at: index+1)

        case (.horizontal, .leading), (.vertical, .top):
            editorLayouts.insert(.one(editor), at: index)

        case (.horizontal, .top):
            editorLayouts[index] = .vertical(.init(.vertical, editorLayouts: [.one(editor), editorLayouts[index]]))

        case (.horizontal, .bottom):
            editorLayouts[index] = .vertical(.init(.vertical, editorLayouts: [editorLayouts[index], .one(editor)]))

        case (.vertical, .leading):
            editorLayouts[index] = .horizontal(.init(.horizontal, editorLayouts: [.one(editor), editorLayouts[index]]))

        case (.vertical, .trailing):
            editorLayouts[index] = .horizontal(.init(.horizontal, editorLayouts: [editorLayouts[index], .one(editor)]))
        }
    }

    /// Closes an Editor.
    /// - Parameter id: ID of the Editor.
    func closeEditor(with id: Editor.ID) {
        editorLayouts.removeAll { editorLayout in
            if case .one(let editor) = editorLayout {
                if editor.id == id {
                    return true
                }
            }

            return false
        }
    }

    func getEditorLayout(with id: Editor.ID) -> EditorLayout? {
        for editorLayout in editorLayouts {
            if case .one(let editor) = editorLayout {
                if editor.id == id {
                    return editorLayout
                }
            }
        }

        return nil
    }

    /// Flattens the splitviews.
    func flatten() {
        for index in editorLayouts.indices {
            editorLayouts[index].flatten(parent: self)
        }
    }

    /// Gets flattened splitviews.
    func getFlattened() -> [Editor] {
        var arr: [Editor] = []
        for index in editorLayouts.indices {
            arr += editorLayouts[index].getFlattened(parent: self)
        }
        return arr
    }
}

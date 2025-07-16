//
//  EditorLayout.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 06/02/2023.
//

import Foundation

enum EditorLayout: Equatable {
    case one(Editor)
    case vertical(SplitViewData)
    case horizontal(SplitViewData)

    /// Closes all tabs which present the given file
    /// - Parameter file: a file.
    func closeAllTabs(of file: CEWorkspaceFile) {
        switch self {
        case .one(let editor):
            editor.removeTab(file)
        case .vertical(let data), .horizontal(let data):
            data.editorLayouts.forEach {
                $0.closeAllTabs(of: file)
            }
        }
    }

    /// Returns some editor, except the given editor.
    /// - Parameter except: the search will exclude this editor.
    /// - Returns: Some editor.
    func findSomeEditor(except: Editor? = nil) -> Editor? {
        switch self {
        case .one(let editor) where editor != except:
            return editor
        case .vertical(let data), .horizontal(let data):
            for editorLayout in data.editorLayouts {
                if let result = editorLayout.findSomeEditor(except: except), result != except {
                    return result
                }
            }
            return nil
        default:
            return nil
        }
    }

    func find(editor id: UUID) -> Editor? {
        switch self {
        case .one(let editor):
            if editor.id == id {
                return editor
            }
        case .vertical(let splitViewData), .horizontal(let splitViewData):
            for layout in splitViewData.editorLayouts {
                if let editor = layout.find(editor: id) {
                    return editor
                }
            }
        }

        return nil
    }

    /// Forms a set of all files currently represented by tabs.
    func gatherOpenFiles() -> Set<CEWorkspaceFile> {
        switch self {
        case .one(let editor):
            return Set(editor.tabs.map { $0.file })
        case .vertical(let data), .horizontal(let data):
            return data.editorLayouts.map { $0.gatherOpenFiles() }.reduce(into: []) { $0.formUnion($1) }
        }
    }

    /// Flattens the splitviews.
    mutating func flatten(parent: SplitViewData) {
        switch self {
        case .one:
            break
        case .horizontal(let data), .vertical(let data):
            if data.editorLayouts.count == 1 {
                let one = data.editorLayouts[0]
                if case .one(let editor) = one {
                    editor.parent = parent
                }
                self = one
            } else {
                data.flatten()
            }
        }
    }

    /// Gets flattened splitviews.
    func getFlattened(parent: SplitViewData) -> [Editor] {
        switch self {
        case .one(let editor):
            return [editor]
        case .horizontal(let data), .vertical(let data):
            if data.editorLayouts.count == 1 {
                let one = data.editorLayouts[0]
                if case .one(let editor) = one {
                    return [editor]
                }
                return []
            } else {
                return data.getFlattened()
            }
        }
    }

    var isEmpty: Bool {
        switch self {
        case .one:
            return false
        case .vertical(let splitViewData), .horizontal(let splitViewData):
            return splitViewData.editorLayouts.allSatisfy { editorLayout in
                editorLayout.isEmpty
            }
        }
    }

    static func == (lhs: EditorLayout, rhs: EditorLayout) -> Bool {
        switch (lhs, rhs) {
        case let (.one(lhs), .one(rhs)):
            return lhs == rhs
        case let (.vertical(lhs), .vertical(rhs)):
            return lhs.editorLayouts == rhs.editorLayouts
        case let (.horizontal(lhs), .horizontal(rhs)):
            return lhs.editorLayouts == rhs.editorLayouts
        default:
            return false
        }
    }
}

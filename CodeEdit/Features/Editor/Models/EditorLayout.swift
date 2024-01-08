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
            editor.tabs.remove(file)
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

    /// Forms a set of all files currently represented by tabs.
    func gatherOpenFiles() -> Set<CEWorkspaceFile> {
        switch self {
        case .one(let editor):
            return Set(editor.tabs)
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

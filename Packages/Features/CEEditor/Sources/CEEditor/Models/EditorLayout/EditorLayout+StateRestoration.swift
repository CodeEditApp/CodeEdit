//
//  Editor+StateRestoration.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/3/23.
//

import Foundation
import CodeEditCore
import SwiftUI
import OrderedCollections

extension EditorManager {
    /// Restores the tab manager from a captured state obtained using `saveRestorationState`
    /// - Parameters:
    ///   - statePersistence: The persistence service to retrieve saved state from.
    ///   - fileManager: The file manager to resolve file references.
    ///   - findReplaceQuery: The shared find/replace query for editor instances.
    public func restoreFromState(
        statePersistence: any WorkspaceStatePersisting,
        fileManager: (any WorkspaceFileProviding)?,
        findReplaceQuery: FindReplaceQuery?
    ) {
        defer {
            // No matter what, set up each editor. Even if we fail to read data.
            flattenedEditors.forEach { editor in
                editor.findReplaceQuery = findReplaceQuery
                editor.editorManager = self
                editor.isAttachedToWorkspace = true
            }
        }

        let restorer = EditorRestorer()
        switch restorer.execute(
            statePersistence: statePersistence,
            fileManager: fileManager,
            findReplaceQuery: findReplaceQuery,
            editorManager: self
        ) {
        case let .restored(layout, activeEditor):
            self.editorLayout = layout
            self.activeEditor = activeEditor
            switchToActiveEditor()
        case .shouldInitCleanState:
            initCleanState()
        case .noChange:
            break
        }
    }

    public func saveRestorationState(_ statePersistence: any WorkspaceStatePersisting) {
        if let data = try? JSONEncoder().encode(
            EditorRestorationState(activeEditor: activeEditor.id, groups: editorLayout)
        ) {
            statePersistence.set(key: .openTabs, value: data)
        } else {
            statePersistence.set(key: .openTabs, value: nil)
        }
    }
}

public struct EditorRestorationState: Codable {
    public var activeEditor: UUID
    public var groups: EditorLayout
}

extension EditorLayout: Codable {
    fileprivate enum EditorLayoutType: String, Codable {
        case one
        case vertical
        case horizontal
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case tabs
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(EditorLayoutType.self, forKey: .type)
        switch type {
        case .one:
            let editor = try container.decode(Editor.self, forKey: .tabs)
            self = .one(editor)
        case .vertical:
            let editor = try container.decode(SplitViewData.self, forKey: .tabs)
            self = .vertical(editor)
        case .horizontal:
            let editor = try container.decode(SplitViewData.self, forKey: .tabs)
            self = .horizontal(editor)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .one(data):
            try container.encode(EditorLayoutType.one, forKey: .type)
            try container.encode(data, forKey: .tabs)
        case let .vertical(data):
            try container.encode(EditorLayoutType.vertical, forKey: .type)
            try container.encode(data, forKey: .tabs)
        case let .horizontal(data):
            try container.encode(EditorLayoutType.horizontal, forKey: .type)
            try container.encode(data, forKey: .tabs)
        }
    }
}

extension SplitViewData: Codable {
    fileprivate enum SplitViewAxis: String, Codable {
        case vertical, horizontal

        init(_ swiftUI: Axis) {
            switch swiftUI {
            case .vertical: self = .vertical
            case .horizontal: self = .horizontal
            }
        }

        var swiftUI: Axis {
            switch self {
            case .vertical: return .vertical
            case .horizontal: return .horizontal
            }
        }
    }

    public enum CodingKeys: String, CodingKey {
        case editorLayouts
        case axis
    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let axis = try container.decode(SplitViewAxis.self, forKey: .axis).swiftUI
        let editorLayouts = try container.decode([EditorLayout].self, forKey: .editorLayouts)
        self.init(axis, editorLayouts: editorLayouts)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(editorLayouts, forKey: .editorLayouts)
        try container.encode(SplitViewAxis(axis), forKey: .axis)
    }
}

extension Editor: Codable {
    public enum CodingKeys: String, CodingKey {
        case tabs
        case selectedTab
        case id
    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fileURLs = try container.decode([URL].self, forKey: .tabs)
        let selectedTab = try? container.decode(URL.self, forKey: .selectedTab)
        let id = try container.decode(UUID.self, forKey: .id)
        self.init(
            files: OrderedSet(fileURLs.map { CEWorkspaceFile(url: $0) }),
            selectedTab: selectedTab == nil ? nil : EditorInstance(
                findReplaceQuery: nil,
                file: CEWorkspaceFile(url: selectedTab!)
            ),
            parent: nil,
            findReplaceQuery: nil
        )
        self.id = id
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tabs.map { $0.file.url }, forKey: .tabs)
        try container.encode(selectedTab?.file.url, forKey: .selectedTab)
        try container.encode(id, forKey: .id)
    }
}

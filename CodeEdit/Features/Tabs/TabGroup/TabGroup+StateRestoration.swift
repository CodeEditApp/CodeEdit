//
//  TabGroup+StateRestoration.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/3/23.
//

import Foundation
import SwiftUI
import OrderedCollections

struct TabRestorationState: Codable {
    var focus: TabGroupData
    var groups: TabGroup
}

extension TabGroup: Codable {
    fileprivate enum TabGroupType: String, Codable {
        case one
        case vertical
        case horizontal
    }

    enum CodingKeys: String, CodingKey {
        case type
        case tabs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(TabGroupType.self, forKey: .type)
        switch type {
        case .one:
            let tabGroupData = try container.decode(TabGroupData.self, forKey: .tabs)
            self = .one(tabGroupData)
        case .vertical:
            let splitViewData = try container.decode(SplitViewData.self, forKey: .tabs)
            self = .vertical(splitViewData)
        case .horizontal:
            let splitViewData = try container.decode(SplitViewData.self, forKey: .tabs)
            self = .horizontal(splitViewData)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .one(data):
            try container.encode(TabGroupType.one, forKey: .type)
            try container.encode(data, forKey: .tabs)
        case let .vertical(data):
            try container.encode(TabGroupType.vertical, forKey: .type)
            try container.encode(data, forKey: .tabs)
        case let .horizontal(data):
            try container.encode(TabGroupType.horizontal, forKey: .type)
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

    enum CodingKeys: String, CodingKey {
        case tabgroups
        case axis
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let axis = try container.decode(SplitViewAxis.self, forKey: .axis).swiftUI
        let tabgroups = try container.decode([TabGroup].self, forKey: .tabgroups)
        self.init(axis, tabgroups: tabgroups)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tabgroups, forKey: .tabgroups)
        try container.encode(SplitViewAxis(axis), forKey: .axis)
    }
}

extension TabGroupData: Codable {
    enum CodingKeys: String, CodingKey {
        case tabs
        case selected
        case id
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fileURLs = try container.decode([URL].self, forKey: .tabs)
        let selected = try? container.decode(URL.self, forKey: .selected)
        let id = try container.decode(UUID.self, forKey: .id)
        self.init(
            files: OrderedSet(fileURLs.map { CEWorkspaceFile(url: $0) }),
            selected: selected == nil ? nil : CEWorkspaceFile(url: selected!),
            parent: nil
        )
        self.id = id
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tabs.map { $0.url }, forKey: .tabs)
        try container.encode(selected?.url, forKey: .selected)
        try container.encode(id, forKey: .id)
    }
}

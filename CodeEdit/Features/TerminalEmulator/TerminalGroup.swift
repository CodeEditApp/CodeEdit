//
//  UtilityAreaTerminalItem.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 23/12/23.
//

import SwiftUI

final class TerminalGroup: ObservableObject, Identifiable, Hashable {
    @Published var customTitle: String?
    @Published var children: [TerminalEmulator] = []
    @Published var isExpanded = true

    init(title customTitle: String? = nil, children: [TerminalEmulator]) {
        self.customTitle = customTitle
        for child in children {
            child.move(to: self)
        }
    }

    var title: String {
        // TODO: Localize this
        customTitle ?? "\(children.count) terminals"
    }

    static func == (lhs: TerminalGroup, rhs: TerminalGroup) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Cache

    private static var cache: [UUID: CacheEntry] = [:]
    private let cacheIdentifier = UUID()

    deinit {
        TerminalGroup.cache.removeValue(forKey: cacheIdentifier)
    }

    private struct CacheEntry {
        unowned let group: TerminalGroup
    }

    static func resolve(_ identifier: UUID) -> TerminalGroup? {
        cache[identifier]?.group
    }

}
extension TerminalGroup: Transferable {

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.cacheIdentifier.uuidString) {
            guard let uuid = UUID(uuidString: $0) else {
                throw ImportError.invalidCacheIdentifier($0)
            }
            guard let group = TerminalGroup.resolve(uuid) else {
                guard let terminal = TerminalEmulator.resolve(uuid) else {
                    throw ImportError.groupNotFound(uuid)
                }
                var group: TerminalGroup!
                if !Thread.isMainThread {
                    DispatchQueue.main.sync {
                        group = TerminalGroup(children: [terminal])
                    }
                } else {
                    group = TerminalGroup(children: [terminal])
                }
                return group
            }
            return group
        }
        .visibility(.ownProcess)
    }

    enum ImportError: Error {
        case invalidCacheIdentifier(String)
        case groupNotFound(UUID)
    }

}

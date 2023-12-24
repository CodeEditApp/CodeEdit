//
//  UtilityAreaTerminalItem.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 23/12/23.
//

import SwiftUI

final class UtilityAreaTerminalGroup: ObservableObject, Identifiable, Hashable {
    @Published var customTitle: String?
    @Published var children: [TerminalEmulator]

    init(title customTitle: String? = nil, children: [TerminalEmulator]) {
        self.customTitle = customTitle
        self.children = children
    }

    var title: String {
        // TODO: Localize this
        customTitle ?? "\(children.count) terminals"
    }

    static func == (lhs: UtilityAreaTerminalGroup, rhs: UtilityAreaTerminalGroup) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Cache

    private static var cache: [UUID: CacheEntry] = [:]
    private let cacheIdentifier = UUID()

    deinit {
        UtilityAreaTerminalGroup.cache.removeValue(forKey: cacheIdentifier)
    }

    private struct CacheEntry {
        unowned let group: UtilityAreaTerminalGroup
    }

    static func resolve(_ identifier: UUID) -> UtilityAreaTerminalGroup? {
        cache[identifier]?.group
    }

}
extension UtilityAreaTerminalGroup: Transferable {

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.cacheIdentifier.uuidString) {
            guard let uuid = UUID(uuidString: $0) else {
                throw ImportError.invalidCacheIdentifier($0)
            }
            guard let group = UtilityAreaTerminalGroup.resolve(uuid) else {
                throw ImportError.groupNotFound(uuid)
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

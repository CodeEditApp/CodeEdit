//
//  ExtensionNavigatorData.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 7.04.22.
//

import Foundation
import Combine

final class ExtensionNavigatorData: ObservableObject {
    @Published var plugins = [Plugin]()

    // Tells if all records have been loaded. (Used to hide/show activity spinner)
    var listFull = false
    // Tracks last page loaded. Used to load next page (current + 1)
    var currentPage = 1
    // Limit of records per page. (Only if backend supports, it usually does)
    let perPage = 10

    private var cancellable: AnyCancellable?

    func fetch() {
        cancellable = ExtensionsStoreAPI.plugins(page: currentPage)
            .tryMap { $0.items }
            .catch { _ in Just(self.plugins) }
            .sink { [weak self] in
                self?.currentPage += 1
                self?.plugins.append(contentsOf: $0)
                // If count of data received is less than perPage value then it is last page.
                if $0.count < self?.perPage ?? 10 {
                    self?.listFull = true
                }
        }
    }

    func install(_ plugin: Plugin) {
        // ExtensionsManager.shared?.install(plugin: plugin, release: .ini)
    }
}

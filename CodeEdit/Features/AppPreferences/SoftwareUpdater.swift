//
//  SoftwareUpdater.swift
//  CodeEdit
//
//  Created by Austin Condiff on 9/19/22.
//

import Foundation
import Sparkle

class SoftwareUpdater: NSObject, ObservableObject, SPUUpdaterDelegate {
    private var updater: SPUUpdater?
    private var automaticallyChecksForUpdatesObservation: NSKeyValueObservation?
    private var lastUpdateCheckDateObservation: NSKeyValueObservation?

    @Published
    var automaticallyChecksForUpdates = false {
        didSet {
            updater?.automaticallyChecksForUpdates = automaticallyChecksForUpdates
        }
    }

    @Published
    var lastUpdateCheckDate: Date?

    @Published
    var includePrereleaseVersions = false {
        didSet {
            UserDefaults.standard.setValue(includePrereleaseVersions, forKey: "includePrereleaseVersions")
        }
    }

    override init() {
        super.init()
        updater = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: self,
            userDriverDelegate: nil
        ).updater

        updater?.setFeedURL(.appcast)

        automaticallyChecksForUpdatesObservation = updater?.observe(
            \.automaticallyChecksForUpdates,
            options: [.initial, .new, .old],
            changeHandler: { [unowned self] updater, change in
                guard change.newValue != change.oldValue else { return }
                self.automaticallyChecksForUpdates = updater.automaticallyChecksForUpdates
            }
        )

        lastUpdateCheckDateObservation = updater?.observe(
            \.lastUpdateCheckDate,
            options: [.initial, .new, .old],
            changeHandler: { [unowned self] updater, _ in
                self.lastUpdateCheckDate = updater.lastUpdateCheckDate
            }
        )

        includePrereleaseVersions = UserDefaults.standard.bool(forKey: "includePrereleaseVersions")
    }

    func allowedChannels(for updater: SPUUpdater) -> Set<String> {
        if includePrereleaseVersions {
            return ["dev"]
        }
        return []
    }

    func checkForUpdates() {
        updater?.checkForUpdates()
    }
}

extension URL {
    static let appcast = URL(
        string: "https://github.com/CodeEditApp/CodeEdit/releases/download/latest/appcast.xml"
    )!
}

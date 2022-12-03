//
//  SoftwareUpdater.swift
//  CodeEdit
//
//  Created by Austin Condiff on 9/19/22.
//

import Foundation
import Sparkle

class SoftwareUpdater: ObservableObject {
    private let updater: SPUUpdater
    private var automaticallyChecksForUpdatesObservation: NSKeyValueObservation?
    private var lastUpdateCheckDateObservation: NSKeyValueObservation?

    @Published
    var automaticallyChecksForUpdates = false {
        didSet {
            updater.automaticallyChecksForUpdates = automaticallyChecksForUpdates
        }
    }

    @Published
    var lastUpdateCheckDate: Date?

    @Published
    var includePrereleaseVersions = false {
        didSet {
            UserDefaults.standard.setValue(includePrereleaseVersions, forKey: "includePrereleaseVersions")
            if includePrereleaseVersions {
                updater.setFeedURL(.prereleaseAppcast)
            } else {
                updater.setFeedURL(.appcast)
            }
        }
    }

    init() {
        updater = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        ).updater

        automaticallyChecksForUpdatesObservation = updater.observe(
            \.automaticallyChecksForUpdates,
            options: [.initial, .new, .old],
            changeHandler: { [unowned self] updater, change in
                guard change.newValue != change.oldValue else { return }
                self.automaticallyChecksForUpdates = updater.automaticallyChecksForUpdates
            }
        )

        lastUpdateCheckDateObservation = updater.observe(
            \.lastUpdateCheckDate,
            options: [.initial, .new, .old],
            changeHandler: { [unowned self] updater, _ in
                self.lastUpdateCheckDate = updater.lastUpdateCheckDate
            }
        )

        includePrereleaseVersions = UserDefaults.standard.bool(forKey: "includePrereleaseVersions")
    }

    func checkForUpdates() {
        updater.checkForUpdates()
    }
}

extension URL {
    static let appcast = URL(string: "https://codeeditapp.github.io/CodeEdit/appcast.xml")!
    static let prereleaseAppcast = URL(string: "https://codeeditapp.github.io/CodeEdit/appcast_pre.xml")!
}

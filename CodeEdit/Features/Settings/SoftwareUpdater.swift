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

    private var feedURLTask: Task<(), Never>?

    private func setFeedURL() async {
        let url = URL(string: "https://api.github.com/repos/CodeEditApp/CodeEdit/releases/latest")!
        let request = URLRequest(url: url)
        guard let data = try? await URLSession.shared.data(for: request),
              let result = try? JSONDecoder().decode(GHAPIResult.self, from: data.0) else {
            DispatchQueue.main.async {
                self.updater?.setFeedURL(nil)
            }
            return
        }
        URL.appcast = URL(
            string: "https://github.com/CodeEditApp/CodeEdit/releases/download/\(result.tagName)/appcast.xml"
        )!
        DispatchQueue.main.async {
            self.updater?.setFeedURL(.appcast)
        }
    }

    override init() {
        super.init()
        updater = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: self,
            userDriverDelegate: nil
        ).updater

        feedURLTask = Task {
            await setFeedURL()
        }

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

    deinit {
        feedURLTask?.cancel()
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

    private struct GHAPIResult: Codable {
        enum CodingKeys: String, CodingKey {
            case tagName = "tag_name"
        }

        var tagName: String
    }
}

extension URL {
    static var appcast = URL(
        string: "https://github.com/CodeEditApp/CodeEdit/releases/download/latest/appcast.xml"
    )!
}

// https://github.com/CodeEditApp/CodeEdit/releases/download/0.0.1-alpha.10/appcast.xml

//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

public class ThemeModel: ObservableObject {

    public static let shared: ThemeModel = .init()

    @Published
    var selectedAppearance: Int = 0

    @Published
    var selectedTab: Int = 2

    @Published
    public var themes: [Theme] = [] {
        didSet {
            try? saveThemes()
            objectWillChange.send()
        }
    }

    @Published
    public var selectedTheme: Theme?

    public var darkThemes: [Theme] {
        themes.filter { $0.appearance == .dark }
    }

    public var lightThemes: [Theme] {
        themes.filter { $0.appearance == .light }
    }

    init() {
        do {
            try loadThemes()
            self.selectedTheme = themes.first
        } catch {
            print(error)
        }
    }

    private func load(from url: URL) throws {
        let json = try Data(contentsOf: url)
        let theme = try JSONDecoder().decode(Theme.self, from: json)
        self.themes.append(theme)
    }

    public func loadThemes() throws {
        themes.removeAll()
        let url = baseURL.appendingPathComponent("themes")

        var isDir: ObjCBool = false

        if !filemanager.fileExists(atPath: url.path, isDirectory: &isDir) {
            try filemanager.createDirectory(at: url, withIntermediateDirectories: true)
        }

        let content = try filemanager.contentsOfDirectory(atPath: url.path).filter { $0.contains(".json") }
        if content.isEmpty {
            guard let defaultUrl = Bundle.main.url(forResource: "default-dark", withExtension: "json") else {
                return
            }
            try load(from: defaultUrl)
            return
        }
        try content.forEach { file in
            let fileURL = url.appendingPathComponent(file)
            try load(from: fileURL)
        }
    }

    private func saveThemes() throws {
        let url = baseURL.appendingPathComponent("themes")
        try themes.forEach { theme in
            let data = try JSONEncoder().encode(theme)
            let json = try JSONSerialization.jsonObject(with: data)
            let prettyJSON = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
            try prettyJSON.write(
                to: url.appendingPathComponent(theme.name).appendingPathExtension("json"),
                options: .atomic
            )
        }
    }

    public let filemanager = FileManager.default
    public var baseURL: URL {
        filemanager.homeDirectoryForCurrentUser.appendingPathComponent(".codeedit")
    }
}

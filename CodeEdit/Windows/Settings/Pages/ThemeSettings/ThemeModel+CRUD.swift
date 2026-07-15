//
//  ThemeModel+CRUD.swift
//  CodeEdit
//
//  Created by Austin Condiff on 6/18/24.
//

import SwiftUI
import CodeEditSettings
import UniformTypeIdentifiers

extension ThemeModel {
    /// Loads all available themes from disk, applies overrides, and selects the initial theme.
    func loadThemes() throws {
        themes.removeAll()

        let prefs = Settings.shared.preferences
        themes = try repository.loadAllThemes(overrides: prefs.theme.overrides)

        // Select initial themes based on preferences
        self.selectedDarkTheme = self.darkThemes.first {
            $0.name == prefs.theme.selectedDarkTheme
        } ?? self.darkThemes.first

        self.selectedLightTheme = self.lightThemes.first {
            $0.name == prefs.theme.selectedLightTheme
        } ?? self.lightThemes.first

        let userSelectedTheme = self.themes.first { $0.name == prefs.theme.selectedTheme }
        let systemAppearance = NSAppearance.currentDrawing().name

        if userSelectedTheme != nil {
            self.selectedTheme = userSelectedTheme
        } else {
            if systemAppearance == .darkAqua {
                self.selectedTheme = self.selectedDarkTheme
            } else {
                self.selectedTheme = self.selectedLightTheme
            }
        }
    }

    func importTheme() {
        let openPanel = NSOpenPanel()
        let allowedTypes = [UTType(filenameExtension: "cetheme")!]

        openPanel.prompt = "Import"
        openPanel.allowedContentTypes = allowedTypes
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false

        openPanel.begin { result in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                if let url = openPanel.urls.first {
                    self.duplicate(url)
                }
            }
        }
    }

    func duplicate(_ url: URL) {
        do {
            self.isAdding = true

            let isBundledURL = bundledThemesURL?.absoluteString ?? ""
            let isImporting =
                !url.absoluteString.hasPrefix(isBundledURL)
                && !url.absoluteString.hasPrefix(themesURL.absoluteString)

            let (destinationURL, newFileName) = try repository.duplicateFile(from: url)

            try self.loadThemes()

            if let index = self.themes.firstIndex(where: { $0.fileURL == destinationURL }) {
                self.themes[index].displayName = newFileName
                self.themes[index].name = newFileName.lowercased().replacingOccurrences(of: " ", with: "-")

                if isImporting != true {
                    self.themes[index].author = NSFullUserName()
                    self.save(self.themes[index])
                }

                self.previousTheme = self.selectedTheme

                activateTheme(self.themes[index])

                self.detailsTheme = self.themes[index]
                self.detailsIsPresented = true
            }
        } catch {
            print("Error adding theme: \(error.localizedDescription)")
        }
    }

    func rename(to newName: String, theme: Theme) {
        do {
            let existingNames = themes.filter { $0 != theme }.map(\.displayName)
            _ = try repository.rename(theme, to: newName, existingNames: existingNames)
            try self.loadThemes()
        } catch {
            print("Error renaming theme: \(error.localizedDescription)")
        }
    }

    /// Save theme to file
    func save(_ theme: Theme) {
        do {
            try repository.save(theme)
        } catch {
            print("Error saving theme: \(error.localizedDescription)")
        }
    }

    /// Removes the given theme from disk and reloads.
    func delete(_ theme: Theme) {
        do {
            try repository.delete(theme)
            Settings.shared.preferences.theme.overrides.removeValue(forKey: theme.name)
            try self.loadThemes()
        } catch {
            print(error)
        }
    }
}

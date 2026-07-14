//
//  ThemeModel+Export.swift
//  CodeEdit
//
//  Created by Austin Condiff on 6/18/24.
//

import SwiftUI
import CodeEditSettings
import UniformTypeIdentifiers

/// Export dialog methods for themes.
extension ThemeModel {
    func exportTheme(_ theme: Theme) {
        guard let themeFileURL = theme.fileURL else {
            print("Theme file URL not found.")
            return
        }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType(filenameExtension: "cetheme")!]
        savePanel.nameFieldStringValue = theme.displayName
        savePanel.prompt = "Export"
        savePanel.canCreateDirectories = true

        savePanel.begin { response in
            if response == .OK, let destinationURL = savePanel.url {
                do {
                    try FileManager.default.copyItem(at: themeFileURL, to: destinationURL)
                    print("Theme exported successfully to \(destinationURL.path)")
                } catch {
                    print("Failed to export theme: \(error.localizedDescription)")
                }
            }
        }
    }

    func exportAllCustomThemes() {
        let openPanel = NSOpenPanel()
        openPanel.prompt = "Export"
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false

        openPanel.begin { result in
            if result == .OK, let exportDirectory = openPanel.url {
                let customThemes = self.themes.filter { !$0.isBundled }

                for theme in customThemes {
                    guard let sourceURL = theme.fileURL else { continue }

                    let destinationURL = exportDirectory.appending(path: "\(theme.displayName).cetheme")

                    do {
                        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                        print("Exported \(theme.displayName) to \(destinationURL.path)")
                    } catch {
                        print("Failed to export \(theme.displayName): \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

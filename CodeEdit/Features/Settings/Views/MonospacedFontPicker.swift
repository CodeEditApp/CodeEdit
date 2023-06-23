//
//  MonospacedFontPicker.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/22/23.
//

import SwiftUI

struct MonospacedFontPicker: View {
    var title: String
    @Binding var selectedFontName: String
    @State var recentFonts: [String]
    @State var monospacedFontFamilyNames: [String] = []
    @State var otherFontFamilyNames: [String] = []

    init(title: String, selectedFontName: Binding<String>) {
        self.title = title
        self._selectedFontName = selectedFontName
        self.recentFonts = UserDefaults.standard.stringArray(forKey: "recentFonts") ?? []
    }

    private func pushIntoRecentFonts(_ newItem: String) {
        recentFonts.removeAll(where: { $0 == newItem })
        recentFonts.insert(newItem, at: 0)
        if recentFonts.count > 3 {
            recentFonts.removeLast()
        }
        UserDefaults.standard.set(recentFonts, forKey: "recentFonts")
    }

    func getFonts() {
        DispatchQueue.global(qos: .userInitiated).async {
            let availableFontFamilies = NSFontManager.shared.availableFontFamilies

            self.monospacedFontFamilyNames = availableFontFamilies.filter { fontFamilyName in
                let fontNames = NSFontManager.shared.availableMembers(ofFontFamily: fontFamilyName) ?? []
                return fontNames.contains { fontName in
                    guard let font = NSFont(name: "\(fontName[0])", size: 14) else {
                        return false
                    }
                    return font.isFixedPitch && font.numberOfGlyphs > 26
                }
            }
            .filter { $0 != "SF Mono" }

            self.otherFontFamilyNames = availableFontFamilies.filter { fontFamilyName in
                let fontNames = NSFontManager.shared.availableMembers(ofFontFamily: fontFamilyName) ?? []
                return fontNames.contains { fontName in
                    guard let font = NSFont(name: "\(fontName[0])", size: 14) else {
                        return false
                    }
                    return !font.isFixedPitch && font.numberOfGlyphs > 26
                }
            }
        }
    }

    var body: some View {
        return Picker(selection: $selectedFontName, label: Text(title)) {
            Text("System Font")
                .font(Font(NSFont.monospacedSystemFont(ofSize: 13.5, weight: .medium)))
                .tag("SF Mono")
            if !recentFonts.isEmpty {
                Divider()
                ForEach(recentFonts, id: \.self) { fontFamilyName in
                    Text(fontFamilyName).font(.custom(fontFamilyName, size: 13.5))
                }
            }
            if !monospacedFontFamilyNames.isEmpty {
                Divider()
                ForEach(monospacedFontFamilyNames, id: \.self) { fontFamilyName in
                    Text(fontFamilyName).font(.custom(fontFamilyName, size: 13.5))
                }
            }
            if !otherFontFamilyNames.isEmpty {
                Divider()
                Picker(selection: $selectedFontName, label: Text("Other fonts...")) {
                    ForEach(otherFontFamilyNames, id: \.self) { fontFamilyName in
                        Text(fontFamilyName)
                            .font(.custom(fontFamilyName, size: 13.5))
                    }
                }
            }
        }
        .onChange(of: selectedFontName) { _ in
            if selectedFontName != "SF Mono" {
                pushIntoRecentFonts(selectedFontName)
            }
        }
        .onAppear(perform: getFonts)
    }
}

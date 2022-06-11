//
//  CodeEditor.swift
//  CodeEditModules/CodeFile
//
//  Created by Marco Carnevali on 19/03/22.
//

import Foundation
import AppKit
import SwiftUI
import Highlightr
import AppPreferences
import Combine
import CodeEditUtils

struct CodeEditor: NSViewRepresentable {
    @State
    private var isCurrentlyUpdatingView: ReferenceTypeBool = .init(value: false)

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    private var content: Binding<String>
    private let language: CodeLanguage?
    private let highlightr = Highlightr()

    private var themeString: String {
        ThemeModel.shared.selectedTheme?.highlightrThemeString ?? ""
    }

    private var lineGutterColor: NSColor {
        if let color = ThemeModel.shared.selectedTheme?.editor.text.color {
            return .init(hex: color).withAlphaComponent(0.5)
        }
        return .tertiaryLabelColor
    }

    init(
        content: Binding<String>,
        language: CodeLanguage?
    ) {
        self.content = content
        self.language = language
        highlightr?.setTheme(theme: .init(themeString: themeString))
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = CodeEditorTextView(
            textContainer: buildTextStorage(
                language: language,
                scrollView: scrollView
            )
        )

        if let highlightr = highlightr,
           let string = highlightr.highlight(
            content.wrappedValue,
            as: language?.id.rawValue,
            fastRender: true
           ) {
            textView.textStorage?.append(string)
        }

        textView.autoresizingMask = .width
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize = NSSize(width: 0, height: scrollView.contentSize.height)
        textView.delegate = context.coordinator
        textView.usesFontPanel = false

        scrollView.drawsBackground = true
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = false
        scrollView.autoresizingMask = [.width, .height]

        scrollView.documentView = textView
        scrollView.verticalRulerView = LineGutter(
            scrollView: scrollView,
            width: 37,
            font: lineGutterFont,
            textColor: lineGutterColor,
            backgroundColor: .clear
        )
        scrollView.rulersVisible = true

        updateTextView(textView)
        return scrollView
    }

    private var lineGutterFont: NSFont {
        let fontSize: Double = 10

        // TODO: calculate the font size depending on the editors font size.

        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .medium)

        let alt0NoSlash: [NSFontDescriptor.FeatureKey: Int] = [
            .selectorIdentifier: 6,
            .typeIdentifier: kStylisticAlternativesType,
        ]

        let alt1NoSerif: [NSFontDescriptor.FeatureKey: Int] = [
            .selectorIdentifier: 8,
            .typeIdentifier: kStylisticAlternativesType,
        ]

        let descriptor = font.fontDescriptor.addingAttributes([.featureSettings: [alt0NoSlash, alt1NoSerif]])

        return NSFont(descriptor: descriptor, size: 0) ?? font
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? CodeEditorTextView else {
            return
        }
        if let rulerView = scrollView.verticalRulerView as? LineGutter {
            if content.wrappedValue != textView.string {
                rulerView.invalidateLineIndices()
            }
            rulerView.font = lineGutterFont
            rulerView.textColor = lineGutterColor
        }
        updateTextView(textView)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        private var content: Binding<String>
        init(content: Binding<String>) {
            self.content = content
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            content.wrappedValue = textView.string
        }

        func textDidBeginEditing(_ notification: Notification) {
            NotificationCenter.default.post(name: NSNotification.Name("CodeEditor.didBeginEditing"), object: nil)
        }

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(content: content)
    }

    private func updateTextView(_ textView: NSTextView) {

        textView.backgroundColor = textViewBackgroundColor()
        guard !isCurrentlyUpdatingView.value else {
            return
        }

        isCurrentlyUpdatingView.value = true

        defer {
            isCurrentlyUpdatingView.value = false
        }

        if let selectedTheme = ThemeModel.shared.selectedTheme {
            textView.insertionPointColor = .init(hex: selectedTheme.editor.insertionPoint.color)
            textView.selectedTextAttributes = [
                .backgroundColor: NSColor(hex: selectedTheme.editor.selection.color)
            ]
        }

        // FIXME: For some reason the theme does not get applied once it is changed (Issue #555)
        // To reproduce: Change the app appearance and then select a different theme.
        // - `themeString` gets changed successfully
        // - background changes accordingly
        highlightr?.setTheme(theme: .init(themeString: themeString))
        if prefs.preferences.textEditing.font.customFont {
            highlightr?.theme.codeFont = .init(
                name: prefs.preferences.textEditing.font.name,
                size: CGFloat(prefs.preferences.textEditing.font.size)
            )
        } else {
            highlightr?.theme.codeFont = .monospacedSystemFont(ofSize: 11, weight: .medium)
        }

        if content.wrappedValue != textView.string {
            if let textStorage = textView.textStorage as? CodeAttributedString {
                textStorage.language = language?.id.rawValue
                textStorage.replaceCharacters(
                    in: NSRange(location: 0, length: textStorage.length),
                    with: content.wrappedValue
                )
            } else {
                textView.string = content.wrappedValue
            }
        }
    }

    private func textViewBackgroundColor() -> NSColor {
        guard let currentTheme = ThemeModel.shared.selectedTheme,
              AppPreferencesModel.shared.preferences.theme.useThemeBackground else {
            return .textBackgroundColor
        }
        return NSColor(hex: currentTheme.editor.background.color)
    }

    private func buildTextStorage(language: CodeLanguage?, scrollView: NSScrollView) -> NSTextContainer {
        // highlightr wrapper that enables real-time highlighting
        let textStorage: CodeAttributedString
        if let highlightr = highlightr {
            textStorage = CodeAttributedString(highlightr: highlightr)
        } else {
            textStorage = CodeAttributedString()
        }
        textStorage.language = language?.id.rawValue
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
        textContainer.widthTracksTextView = true
        textContainer.containerSize = NSSize(
            width: scrollView.contentSize.width,
            height: .greatestFiniteMagnitude
        )
        layoutManager.addTextContainer(textContainer)
        return textContainer
    }
}

extension CodeEditor {
    // A wrapper around a `Bool` that enables updating
    // the wrapped value during `View` renders.
    private final class ReferenceTypeBool {
        var value: Bool

        init(value: Bool) {
            self.value = value
        }
    }
}

//
//  ThemePreviewIcon.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI

struct ThemePreviewIcon: View {
    var theme: Theme
    var colorScheme: ColorScheme

    @Binding
    var selection: Theme?

    init(_ theme: Theme, selection: Binding<Theme?>, colorScheme: ColorScheme) {
        self.theme = theme
        self._selection = selection
        self.colorScheme = colorScheme
    }

    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(Color(hex: colorScheme == .dark ? 0x4c4c4c : 0xbbbbbb))

                HStack(spacing: 1) {
                    sidebar
                    content
                }
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .padding(1)
            }
            .padding(1)
            .frame(width: 130, height: 88)
            .shadow(color: Color(NSColor.shadowColor).opacity(0.1), radius: 8, x: 0, y: 2)
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(lineWidth: 2)
                    .foregroundColor(selection == theme ? .accentColor : .clear)
            }
            Text(theme.displayName)
                .font(.subheadline)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .foregroundColor(selection == theme ? .white : .primary)
                .background(Capsule().foregroundColor(selection == theme ? .accentColor : .clear))
        }
        .help(theme.metadataDescription)
        .onTapGesture {
            withAnimation(.interactiveSpring()) {
                self.selection = theme
            }
        }
    }

    private var sidebar: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .foregroundColor(Color(hex: colorScheme == .dark ? 0x383838 : 0xd0d0d0))
                .frame(width: 36)

            HStack(spacing: 1.5) {
                Circle().foregroundColor(.red)
                Circle().foregroundColor(Color(hex: 0xf9b82d))
                Circle().foregroundColor(.green)
            }
            .frame(width: 12, height: 3)
            .padding(4)
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundColor(Color(hex: colorScheme == .dark ? 0x2b2b2b : 0xe0e0e0))
                .frame(height: 10)
            Rectangle()
                .foregroundColor(theme.editor.background.swiftColor)
                .overlay(alignment: .topLeading) {
                    codeWindow
                }
        }
    }

    private var codeWindow: some View {
        VStack(alignment: .leading, spacing: 4) {
            block1
            block2
            block3
            block4
            block5
        }
        .padding(.top, 6)
        .padding(.leading, 6)
    }

    private var block1: some View {
        codeStatement(theme.editor.comments.color, length: 25)
    }

    private var block2: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 1) {
                codeStatement(theme.editor.keywords.color, length: 6)
                codeStatement(theme.editor.variables.color, length: 6)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.values.color, length: 8)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.values.color, length: 8)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.keywords.color, length: 6)
                codeStatement(theme.editor.strings.color, length: 7)
            }
            HStack(spacing: 1) {
                codeStatement(theme.editor.keywords.color, length: 6)
                codeStatement(theme.editor.variables.color, length: 8)
                codeStatement(theme.editor.keywords.color, length: 6)
                codeStatement(theme.editor.strings.color, length: 12)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeStatement(theme.editor.keywords.color, length: 6)
                codeStatement(theme.editor.strings.color, length: 14)
                codeStatement(theme.editor.text.color, length: 1)
            }
        }
    }

    private var block3: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 1) {
                codeStatement(theme.editor.keywords.color, length: 4)
                codeStatement(theme.editor.variables.color, length: 8)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(3)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(5)
                codeStatement(theme.editor.text.color, length: 3)
                codeStatement(theme.editor.numbers.color, length: 1)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(5)
                codeStatement(theme.editor.text.color, length: 6)
                codeStatement(theme.editor.strings.color, length: 7)
                codeStatement(theme.editor.strings.color, length: 5)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(5)
                codeStatement(theme.editor.text.color, length: 5)
                codeStatement(theme.editor.keywords.color, length: 5)
            }
            HStack(spacing: 1) {
                codeSpace(3)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeStatement(theme.editor.text.color, length: 2)
            }
        }
    }

    private var block4: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 1) {
                codeStatement(theme.editor.keywords.color, length: 6)
                codeStatement(theme.editor.keywords.color, length: 7)
                codeStatement(theme.editor.commands.color, length: 8)
                codeStatement(theme.editor.values.color, length: 3)
                codeStatement(theme.editor.text.color, length: 2)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(3)
                codeStatement(theme.editor.keywords.color, length: 4)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.variables.color, length: 5)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.values.color, length: 8)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.types.color, length: 8)
                codeStatement(theme.editor.text.color, length: 2)
            }
        }
    }

    private var block5: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 1) {
                codeSpace(3)
                codeStatement(theme.editor.keywords.color, length: 4)
                codeStatement(theme.editor.variables.color, length: 10)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.types.color, length: 11)
                codeStatement(theme.editor.text.color, length: 3)
                codeStatement(theme.editor.keywords.color, length: 2)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(5)
                codeStatement(theme.editor.attributes.color, length: 8)
                codeStatement(theme.editor.text.color, length: 2)
                codeStatement(theme.editor.variables.color, length: 5)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.keywords.color, length: 2)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(7)
                codeStatement(theme.editor.keywords.color, length: 3)
                codeStatement(theme.editor.variables.color, length: 12)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(9)
                codeStatement(theme.editor.text.color, length: 3)
                codeStatement(theme.editor.characters.color, length: 1)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(9)
                codeStatement(theme.editor.text.color, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(9)
                codeStatement(theme.editor.text.color, length: 3)
                codeStatement(theme.editor.attributes.color, length: 5)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.types.color, length: 6)
                codeStatement(theme.editor.text.color, length: 1)
                codeStatement(theme.editor.numbers.color, length: 1)
                codeStatement(theme.editor.text.color, length: 1)
            }
        }
    }

    private func codeStatement(_ color: String, length: Double) -> some View {
        Rectangle()
            .foregroundColor(Color(hex: color))
            .frame(width: length, height: 2)
    }

    private func codeSpace(_ length: Double) -> some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: length-1, height: 2)
    }
}

 private struct ThemePreviewIcon_Previews: PreviewProvider {
    static var previews: some View {
        ThemePreviewIcon(ThemeModel.shared.themes.first!,
                         selection: .constant(ThemeModel.shared.themes.first),
                         colorScheme: .light)
            .preferredColorScheme(.light)

        ThemePreviewIcon(ThemeModel.shared.themes.last!,
                         selection: .constant(nil),
                         colorScheme: .dark)
            .preferredColorScheme(.dark)
    }
 }

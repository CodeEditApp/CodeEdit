//
//  ThemePreviewIcon.swift
//  
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI

@available(macOS 12, *)
struct ThemePreviewIcon: View {
    @Environment(\.colorScheme)
    private var colorScheme

    init(_ id: Int, selection: Binding<Int>) {
        self.id = id
        self._selection = selection
    }

    var id: Int

    @Binding
    var selection: Int

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
                    .foregroundColor(selection == id ? .accentColor : .clear)
            }
            Text("Civic")
                .font(.subheadline)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .foregroundColor(selection == id ? .white : .primary)
                .background(Capsule().foregroundColor(selection == id ? .accentColor : .clear))
        }
        .onTapGesture {
            withAnimation(.interactiveSpring()) {
                self.selection = id
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
                .foregroundColor(Color(hex: 0x1f2029))
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
        codeStatement(0x97be71, length: 25)
    }

    private var block2: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 1) {
                codeStatement(0xef8bb6, length: 6)
                codeStatement(0x70c1e2, length: 6)
                codeStatement(0xffffff, length: 1)
                codeStatement(0xffffff, length: 1)
                codeStatement(0x70c1e2, length: 8)
                codeStatement(0xffffff, length: 1)
                codeStatement(0x70c1e2, length: 8)
                codeStatement(0xffffff, length: 1)
                codeStatement(0xef8bb6, length: 6)
                codeStatement(0xf0907f, length: 7)
            }
            HStack(spacing: 1) {
                codeStatement(0xef8bb6, length: 6)
                codeStatement(0x70c1e2, length: 8)
                codeStatement(0xef8bb6, length: 6)
                codeStatement(0xf0907f, length: 12)
                codeStatement(0xffffff, length: 1)
            }
            HStack(spacing: 1) {
                codeStatement(0xef8bb6, length: 6)
                codeStatement(0xf0907f, length: 14)
                codeStatement(0xffffff, length: 1)
            }
        }
    }

    private var block3: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 1) {
                codeStatement(0xef8bb6, length: 4)
                codeStatement(0x70c1e2, length: 8)
                codeStatement(0xffffff, length: 1)
                codeStatement(0xffffff, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(3)
                codeStatement(0xffffff, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(5)
                codeStatement(0xffffff, length: 3)
                codeStatement(0xd6c775, length: 1)
                codeStatement(0xffffff, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(5)
                codeStatement(0xffffff, length: 6)
                codeStatement(0xf0907f, length: 7)
                codeStatement(0xf0907f, length: 5)
                codeStatement(0xffffff, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(5)
                codeStatement(0xffffff, length: 5)
                codeStatement(0xef8bb6, length: 5)
            }
            HStack(spacing: 1) {
                codeSpace(3)
                codeStatement(0xffffff, length: 1)
            }
            HStack(spacing: 1) {
                codeStatement(0xffffff, length: 2)
            }
        }
    }

    private var block4: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 1) {
                codeStatement(0xef8bb6, length: 6)
                codeStatement(0xef8bb6, length: 7)
                codeStatement(0xc6a3f9, length: 8)
                codeStatement(0x70c1e2, length: 3)
                codeStatement(0xffffff, length: 2)
                codeStatement(0xffffff, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(3)
                codeStatement(0xef8bb6, length: 4)
                codeStatement(0xffffff, length: 1)
                codeStatement(0x70c1e2, length: 5)
                codeStatement(0xffffff, length: 1)
                codeStatement(0x70c1e2, length: 8)
                codeStatement(0xffffff, length: 1)
                codeStatement(0xffffff, length: 1)
                codeStatement(0x93c7bc, length: 8)
                codeStatement(0xffffff, length: 2)
            }
        }
    }

    private var block5: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 1) {
                codeSpace(3)
                codeStatement(0xef8bb6, length: 4)
                codeStatement(0x70c1e2, length: 10)
                codeStatement(0xffffff, length: 1)
                codeStatement(0x93c7bc, length: 11)
                codeStatement(0xffffff, length: 3)
                codeStatement(0xef8bb6, length: 2)
                codeStatement(0xffffff, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(5)
                codeStatement(0x93c7bc, length: 8)
                codeStatement(0xffffff, length: 2)
                codeStatement(0x70c1e2, length: 5)
                codeStatement(0xffffff, length: 1)
                codeStatement(0xef8bb6, length: 2)
                codeStatement(0xffffff, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(7)
                codeStatement(0xef8bb6, length: 3)
                codeStatement(0x70c1e2, length: 12)
                codeStatement(0xffffff, length: 1)
                codeStatement(0xffffff, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(9)
                codeStatement(0xffffff, length: 3)
                codeStatement(0x93c7bc, length: 5)
                codeStatement(0xffffff, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(9)
                codeStatement(0xffffff, length: 1)
            }
            HStack(spacing: 1) {
                codeSpace(9)
                codeStatement(0xffffff, length: 3)
                codeStatement(0x93c7bc, length: 5)
                codeStatement(0xffffff, length: 1)
                codeStatement(0x93c7bc, length: 6)
                codeStatement(0xffffff, length: 1)
                codeStatement(0xd6c775, length: 1)
                codeStatement(0xffffff, length: 1)
            }
        }
    }

    private func codeStatement(_ color: Int, length: Double) -> some View {
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

@available(macOS 12, *)
struct ThemePreviewIcon_Previews: PreviewProvider {
    static var previews: some View {
        ThemePreviewIcon(0, selection: .constant(0))
            .background(Color.white)
            .preferredColorScheme(.light)

        ThemePreviewIcon(0, selection: .constant(1))
            .background(Color.white)
            .preferredColorScheme(.dark)
    }
}

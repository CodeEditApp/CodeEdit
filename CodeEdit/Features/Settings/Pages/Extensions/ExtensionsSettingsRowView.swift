//
//  ExtensionsSettingsRowView.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import SwiftUI

struct ExtensionsSettingsRowView: View, Equatable {
    let title: String
    let subtitle: String
    let icon: String
    let onCancel: (() -> Void)
    let onInstall: (() async -> Void)

    private let cleanedTitle: String
    private let cleanedSubtitle: String

    @State private var isHovering: Bool = false
    @State private var isInstalling: Bool = false
    @State private var isInstalled: Bool = false
    @State private var isEnabled = false
    @State private var installProgress: Double = 0.0

    init(
        title: String,
        subtitle: String,
        icon: String,
        onCancel: @escaping (() -> Void),
        onInstall: @escaping () async -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.onCancel = onCancel
        self.onInstall = onInstall

        self.cleanedTitle = title
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { word -> String in
                let str = String(word).lowercased()
                // Check for special cases
                if str == "ls" || str == "lsp" || str == "ci" || str == "cli" {
                    return str.uppercased()
                }
                // Normal capitalization for other words
                return str.prefix(1).uppercased() + str.dropFirst()
            }
            .joined(separator: " ")
        self.cleanedSubtitle = subtitle.replacingOccurrences(of: "\n", with: " ")
    }

    var body: some View {
        HStack {
            Label {
                VStack(alignment: .leading) {
                    Text(cleanedTitle)
                    Text(cleanedSubtitle)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            } icon: {
                Image(icon)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .frame(width: 26, height: 26)
                    .padding(.top, 2)
                    .padding(.bottom, 2)
                    .padding(.leading, 2)
            }
            .opacity(isInstalled && !isEnabled ? 0.5 : 1.0)

            Spacer()

            installationButton()
        }
        .onHover { hovering in
            isHovering = hovering
        }
    }

    @ViewBuilder
    private func installationButton() -> some View {
        if isInstalled {
            HStack {
                if isHovering {
                    Button {
                        isInstalling = false
                        isInstalled = false
                    } label: {
                        Text("Remove")
                    }
                }
                Toggle("", isOn: $isEnabled)
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .labelsHidden()
            }
        } else if isInstalling {
            ZStack {
                CECircularProgressView(progress: installProgress)
                    .frame(width: 20, height: 20)
                Button {
                    isInstalling = false
                    onCancel()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
        } else if isHovering {
            Button {
                isInstalling = true
                withAnimation(.linear(duration: 3)) {
                    installProgress = 0.75
                }
                Task {
                    await onInstall()
                    withAnimation(.linear(duration: 1)) {
                        installProgress = 1.0
                    }
                    isInstalling = false
                    isInstalled = true
                    isEnabled = true
                }
            } label: {
                Text("Install")
            }
        }
    }

    static func == (lhs: ExtensionsSettingsRowView, rhs: ExtensionsSettingsRowView) -> Bool {
        lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
    }
}

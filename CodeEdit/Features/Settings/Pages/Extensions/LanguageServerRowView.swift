//
//  LanguageServerRowView.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import SwiftUI

private let iconSize: CGFloat = 26

struct LanguageServerRowView: View, Equatable {
    let packageName: String
    let subtitle: String
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
        packageName: String,
        subtitle: String,
        isInstalled: Bool = false,
        isEnabled: Bool = false,
        onCancel: @escaping (() -> Void),
        onInstall: @escaping () async -> Void
    ) {
        self.packageName = packageName
        self.subtitle = subtitle
        self.isInstalled = isInstalled
        self.isEnabled = isEnabled
        self.onCancel = onCancel
        self.onInstall = onInstall

        self.cleanedTitle = packageName
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { word -> String in
                let str = String(word).lowercased()
                // Check for special cases
                if str == "ls" || str == "lsp" || str == "ci" || str == "cli" {
                    return str.uppercased()
                }
                return str.capitalized
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
                letterIcon()
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
            installedRow()
        } else if isInstalling {
            isInstallingRow()
        } else if isHovering {
            isHoveringRow()
        }
    }

    @ViewBuilder
    private func installedRow() -> some View {
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
                .onChange(of: isEnabled) { newValue in
                    RegistryManager.shared.installedLanguageServers[packageName]?.isEnabled = newValue
                }
                .toggleStyle(.switch)
                .controlSize(.small)
                .labelsHidden()
        }
    }

    @ViewBuilder
    private func isInstallingRow() -> some View {
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
    }

    @ViewBuilder
    private func isHoveringRow() -> some View {
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

    @ViewBuilder
    private func letterIcon() -> some View {
        RoundedRectangle(cornerRadius: iconSize / 4, style: .continuous)
            .fill(background)
            .overlay {
                Text(String(cleanedTitle.first ?? Character("")))
                    .font(.system(size: iconSize * 0.65))
                    .foregroundColor(.primary)
            }
            .clipShape(RoundedRectangle(cornerRadius: iconSize / 4, style: .continuous))
            .shadow(
                color: Color(NSColor.black).opacity(0.25),
                radius: iconSize / 40,
                y: iconSize / 40
            )
            .frame(width: iconSize, height: iconSize)
    }

    private var background: AnyShapeStyle {
        let colors: [Color] = [
            .blue, .green, .orange, .red, .purple, .pink, .teal, .yellow, .indigo, .cyan
        ]
        let hashValue = abs(cleanedTitle.hashValue) % colors.count
        return AnyShapeStyle(colors[hashValue].gradient)
    }

    static func == (lhs: LanguageServerRowView, rhs: LanguageServerRowView) -> Bool {
        lhs.packageName == rhs.packageName && lhs.subtitle == rhs.subtitle
    }
}

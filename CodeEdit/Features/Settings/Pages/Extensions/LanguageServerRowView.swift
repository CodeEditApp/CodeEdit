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

    private var isInstalled: Bool {
        registryManager.installedLanguageServers[packageName] != nil
    }
    private var isEnabled: Bool {
        registryManager.installedLanguageServers[packageName]?.isEnabled ?? false
    }

    @State private var isHovering: Bool = false
    @State private var showingRemovalConfirmation = false
    @State private var isRemoving = false
    @State private var removalError: Error?
    @State private var showingRemovalError = false

    @State private var showMore: Bool = false

    @EnvironmentObject var registryManager: RegistryManager

    init(
        packageName: String,
        subtitle: String,
        onCancel: @escaping (() -> Void),
        onInstall: @escaping () async -> Void
    ) {
        self.packageName = packageName
        self.subtitle = subtitle
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
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(cleanedSubtitle)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .lineLimit(showMore ? nil : 1)
                            .truncationMode(.tail)
                        if isHovering {
                            Spacer(minLength: 0)
                            Button {
                                showMore.toggle()
                            } label: {
                                Text(showMore ? "Show Less" : "Show More")
                                    .font(.footnote)
                            }
                            .buttonStyle(.plain)
                        }
                    }
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
        .alert("Remove \(cleanedTitle)?", isPresented: $showingRemovalConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                removeLanguageServer()
            }
        } message: {
            Text("Are you sure you want to remove this language server? This action cannot be undone.")
        }
        .alert("Removal Failed", isPresented: $showingRemovalError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(removalError?.localizedDescription ?? "An unknown error occurred")
        }
    }

    @ViewBuilder
    private func installationButton() -> some View {
        if isInstalled {
            installedRow()
        } else if registryManager.runningInstall?.package.name == packageName {
            isInstallingRow()
        } else if isHovering {
            isHoveringRow()
        }
    }

    @ViewBuilder
    private func installedRow() -> some View {
        HStack {
            if isRemoving {
                ProgressView()
                    .controlSize(.small)
            } else if isHovering {
                Button {
                    showingRemovalConfirmation = true
                } label: {
                    Text("Remove")
                }
            }
            Toggle(
                "",
                isOn: Binding(
                    get: { isEnabled },
                    set: { registryManager.setPackageEnabled(packageName: packageName, enabled: $0) }
                )
            )
            .toggleStyle(.switch)
            .controlSize(.small)
            .labelsHidden()
        }
    }

    @ViewBuilder
    private func isInstallingRow() -> some View {
        HStack {
            ZStack {
                CECircularProgressView()
                    .frame(width: 20, height: 20)

                Button {
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
    }

    @ViewBuilder
    private func failedRow() -> some View {
        Button {
            Task {
                await onInstall()
            }
        } label: {
            Text("Retry")
                .foregroundColor(.red)
        }
    }

    @ViewBuilder
    private func isHoveringRow() -> some View {
        Button {
            Task {
                await onInstall()
            }
        } label: {
            Text("Install")
        }
        .disabled(registryManager.isInstalling)
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

    private func removeLanguageServer() {
        isRemoving = true
        Task {
            do {
                try await registryManager.removeLanguageServer(packageName: packageName)
                await MainActor.run {
                    isRemoving = false
                }
            } catch {
                await MainActor.run {
                    isRemoving = false
                    removalError = error
                    showingRemovalError = true
                }
            }
        }
    }

    private var background: AnyShapeStyle {
        let colors: [Color] = [
            .blue, .green, .orange, .red, .purple, .pink, .teal, .yellow, .indigo, .cyan
        ]
        let hashValue = abs(cleanedTitle.hash) % colors.count
        return AnyShapeStyle(colors[hashValue].gradient)
    }

    static func == (lhs: LanguageServerRowView, rhs: LanguageServerRowView) -> Bool {
        lhs.packageName == rhs.packageName && lhs.subtitle == rhs.subtitle
    }
}

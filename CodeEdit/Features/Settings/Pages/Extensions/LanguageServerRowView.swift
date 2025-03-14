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
    @State private var installationStatus: PackageInstallationStatus = .notQueued
    @State private var isInstalled: Bool = false
    @State private var isEnabled = false
    @State private var showingRemovalConfirmation = false
    @State private var isRemoving = false
    @State private var removalError: Error?
    @State private var showingRemovalError = false

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
        .onAppear {
            // Check if this package is already in the installation queue
            installationStatus = InstallationQueueManager.shared.getInstallationStatus(packageName: packageName)
        }
        .onReceive(NotificationCenter.default.publisher(for: .installationStatusChanged)) { notification in
            if let notificationPackageName = notification.userInfo?["packageName"] as? String,
               notificationPackageName == packageName,
               let status = notification.userInfo?["status"] as? PackageInstallationStatus {
                installationStatus = status
                if case .installed = status {
                    isInstalled = true
                    isEnabled = true
                }
            }
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
        } else {
            switch installationStatus {
            case .installing, .queued:
                isInstallingRow()
            case .failed:
                failedRow()
            default:
                if isHovering {
                    isHoveringRow()
                }
            }
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
        HStack {
            if case .queued = installationStatus {
                Text("Queued")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ZStack {
                CECircularProgressView()
                    .frame(width: 20, height: 20)
                Button {
                    InstallationQueueManager.shared.cancelInstallation(packageName: packageName)
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
            // Reset status and retry installation
            installationStatus = .notQueued
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
                try await RegistryManager.shared.removeLanguageServer(packageName: packageName)
                await MainActor.run {
                    isRemoving = false
                    isInstalled = false
                    isEnabled = false
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
        let hashValue = abs(cleanedTitle.hashValue) % colors.count
        return AnyShapeStyle(colors[hashValue].gradient)
    }

    static func == (lhs: LanguageServerRowView, rhs: LanguageServerRowView) -> Bool {
        lhs.packageName == rhs.packageName && lhs.subtitle == rhs.subtitle
    }
}

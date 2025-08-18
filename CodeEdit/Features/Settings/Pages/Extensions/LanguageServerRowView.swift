//
//  LanguageServerRowView.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import SwiftUI

private let iconSize: CGFloat = 26

struct LanguageServerRowView: View, Equatable {
    let package: RegistryItem
    let onCancel: (() -> Void)
    let onInstall: (() async -> Void)

    private var isInstalled: Bool {
        registryManager.installedLanguageServers[package.name] != nil
    }
    private var isEnabled: Bool {
        registryManager.installedLanguageServers[package.name]?.isEnabled ?? false
    }

    @State private var isHovering: Bool = false
    @State private var showingRemovalConfirmation = false
    @State private var isRemoving = false
    @State private var removalError: Error?
    @State private var showingRemovalError = false

    @State private var showMore: Bool = false

    @EnvironmentObject var registryManager: RegistryManager

    init(
        package: RegistryItem,
        onCancel: @escaping (() -> Void),
        onInstall: @escaping () async -> Void
    ) {
        self.package = package
        self.onCancel = onCancel
        self.onInstall = onInstall
    }

    var body: some View {
        HStack {
            Label {
                VStack(alignment: .leading) {
                    Text(package.sanitizedName)

                    ZStack(alignment: .leadingLastTextBaseline) {
                        VStack(alignment: .leading) {
                            Text(package.sanitizedDescription)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .lineLimit(showMore ? nil : 1)
                                .truncationMode(.tail)
                            if showMore {
                                Button(package.homepagePretty) {
                                    guard let url = package.homepageURL else { return }
                                    NSWorkspace.shared.open(url)
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(Color(NSColor.linkColor))
                                .font(.footnote)
                                .cursor(.pointingHand)
                                if let installerName = package.installMethod?.packageManagerType?.rawValue {
                                    Text("Install using \(installerName)")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        if isHovering {
                            HStack {
                                Spacer()
                                Button {
                                    showMore.toggle()
                                } label: {
                                    Text(showMore ? "Show Less" : "Show More")
                                        .font(.footnote)
                                }
                                .buttonStyle(.plain)
                                .background(
                                    Rectangle()
                                        .inset(by: -2)
                                        .fill(.clear)
                                        .background(Color(NSColor.windowBackgroundColor))
                                )
                            }
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
        .alert("Remove \(package.sanitizedName)?", isPresented: $showingRemovalConfirmation) {
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
        } else if registryManager.runningInstall?.package.name == package.name {
            isInstallingRow()
        } else if isHovering {
            isHoveringRow()
        }
    }

    @ViewBuilder
    private func installedRow() -> some View {
        HStack {
            if isRemoving {
                CECircularProgressView()
                    .frame(width: 20, height: 20)
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
                    set: { registryManager.setPackageEnabled(packageName: package.name, enabled: $0) }
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
                Text(String(package.sanitizedName.first ?? Character("")))
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
                try await registryManager.removeLanguageServer(packageName: package.name)
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
        let hashValue = abs(package.sanitizedName.hash) % colors.count
        return AnyShapeStyle(colors[hashValue].gradient)
    }

    static func == (lhs: LanguageServerRowView, rhs: LanguageServerRowView) -> Bool {
        lhs.package.name == rhs.package.name
    }
}

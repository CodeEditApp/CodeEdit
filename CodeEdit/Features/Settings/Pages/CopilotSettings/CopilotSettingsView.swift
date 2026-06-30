//
//  CopilotSettingsView.swift
//  CodeEdit
//
//  Created by Anas Khan on 6/30/26.
//

import SwiftUI

/// The settings page for the GitHub Copilot integration: enable toggle, binary path, and device-flow sign-in.
struct CopilotSettingsView: View {
    @AppSettings(\.copilot.enabled)
    var enabled
    @AppSettings(\.copilot.languageServerPath)
    var languageServerPath

    @ObservedObject private var service: CopilotService = .shared

    var body: some View {
        SettingsForm {
            Section {
                Toggle("Enable GitHub Copilot", isOn: $enabled)
            } header: {
                Text("GitHub Copilot")
                Text("Show AI inline completions as you type. Requires a GitHub Copilot subscription.")
            }

            Section {
                accountRow
            } header: {
                Text("Account")
            }

            Section {
                LabeledContent("Language Server Path") {
                    TextField("Auto-discover", text: $languageServerPath)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 260)
                }
            } header: {
                Text("Advanced")
                Text(
                    "Optional absolute path to the copilot-language-server binary. "
                    + "Leave empty to discover it on your PATH or npm global install."
                )
            }
        }
    }

    @ViewBuilder private var accountRow: some View {
        switch service.authState {
        case .signedOut:
            LabeledContent("Status") {
                HStack {
                    Text("Not signed in")
                        .foregroundStyle(.secondary)
                    signInButton
                }
            }
        case let .awaitingDeviceCode(userCode, verificationUri):
            deviceCodeView(userCode: userCode, verificationUri: verificationUri)
        case let .signedIn(user):
            LabeledContent("Status") {
                HStack {
                    Label("Signed in as \(user)", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Button("Sign Out") {
                        Task { await service.signOut() }
                    }
                    .disabled(service.isBusy)
                }
            }
        case let .error(message):
            LabeledContent("Status") {
                VStack(alignment: .trailing, spacing: 4) {
                    Label(message, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.trailing)
                    signInButton
                }
            }
        }
    }

    private var signInButton: some View {
        Button("Sign In") {
            startSignIn()
        }
        .disabled(service.isBusy)
    }

    @ViewBuilder
    private func deviceCodeView(userCode: String, verificationUri: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Enter this code at GitHub to finish signing in:")
                .foregroundStyle(.secondary)
            HStack {
                Text(userCode)
                    .font(.system(.title2, design: .monospaced, weight: .semibold))
                    .textSelection(.enabled)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color(.textBackgroundColor)))
                Button {
                    copyCodeAndOpen(userCode: userCode, verificationUri: verificationUri)
                } label: {
                    Label("Copy & Open Browser", systemImage: "arrow.up.forward.square")
                }
            }
            HStack(spacing: 6) {
                ProgressView().controlSize(.small)
                Text("Waiting for authorization...")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func startSignIn() {
        Task {
            await service.signIn()
            if case let .awaitingDeviceCode(userCode, verificationUri) = service.authState {
                copyCodeAndOpen(userCode: userCode, verificationUri: verificationUri)
                await service.confirmDeviceFlow()
            }
        }
    }

    private func copyCodeAndOpen(userCode: String, verificationUri: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(userCode, forType: .string)
        if let url = URL(string: verificationUri) {
            NSWorkspace.shared.open(url)
        }
    }
}

//
//  StatusBarCopilotIcon.swift
//  CodeEdit
//
//  Created by Anas Khan on 6/30/26.
//

import SwiftUI

/// A status bar item reflecting the GitHub Copilot state.
///
/// Shows `sparkles` when signed in and idle, a progress indicator while busy, and `sparkles.slash` when signed
/// out or in an error state. Clicking opens the Settings window. Hidden entirely when Copilot is disabled.
struct StatusBarCopilotIcon: View {
    @ObservedObject private var service: CopilotService = .shared

    @Environment(\.openWindow)
    private var openWindow

    var body: some View {
        if service.isEnabled {
            Button {
                openWindow(id: SceneID.settings.rawValue)
            } label: {
                iconContent
            }
            .buttonStyle(.icon)
            .help(helpText)
        }
    }

    @ViewBuilder private var iconContent: some View {
        if service.isBusy {
            ProgressView()
                .controlSize(.small)
                .frame(width: 14, height: 14)
        } else {
            Image(systemName: symbolName)
                .foregroundStyle(tint)
        }
    }

    private var symbolName: String {
        switch service.authState {
        case .signedIn:
            return "sparkles"
        case .signedOut, .awaitingDeviceCode, .error:
            return "sparkles.slash"
        }
    }

    private var tint: Color {
        switch service.authState {
        case .signedIn:
            return .primary
        case .error:
            return .red
        case .signedOut, .awaitingDeviceCode:
            return .secondary
        }
    }

    private var helpText: String {
        switch service.authState {
        case .signedIn(let user):
            return "GitHub Copilot: Signed in as \(user)"
        case .awaitingDeviceCode:
            return "GitHub Copilot: Waiting for authorization"
        case .signedOut:
            return "GitHub Copilot: Not signed in"
        case .error(let message):
            return "GitHub Copilot: \(message)"
        }
    }
}

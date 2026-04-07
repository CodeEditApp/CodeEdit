//
//  SourceControlManager+Alerts.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import AppKit

/// Alert presentation helpers for source control error handling.
extension SourceControlManager {
    /// Show alert for error
    func showAlertForError(title: String, error: Error) async {
        if let error = error as? GitClient.GitClientError {
            await showAlert(title: title, message: error.description)
            return
        }

        if let error = error as? LocalizedError {
            var description = error.errorDescription ?? ""
            if let failureReason = error.failureReason {
                if description.isEmpty {
                    description += failureReason
                } else {
                    description += "\n\n" + failureReason
                }
            }

            if let recoverySuggestion = error.recoverySuggestion {
                if description.isEmpty {
                    description += recoverySuggestion
                } else {
                    description += "\n\n" + recoverySuggestion
                }
            }

            await showAlert(title: title, message: description)
        } else {
            await showAlert(title: title, message: error.localizedDescription)
        }
    }

    func showAlert(title: String, message: String) async {
        await MainActor.run {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .warning
            alert.runModal()
        }
    }
}

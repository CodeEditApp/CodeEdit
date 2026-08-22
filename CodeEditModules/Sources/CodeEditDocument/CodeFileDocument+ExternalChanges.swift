//
//  CodeFileDocument+ExternalChanges.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 22/08/26.
//

import AppKit

/// Reacting to the file changing underneath us on disk.
///
/// **The isolation here is a bridge, not a resolution.** `NSDocument` is main-actor isolated but
/// declares `read(from:ofType:)` and `presentedItemDidChange()` nonisolated, so both override a
/// nonisolated entry point while touching main-actor document state. `MainActor.assumeIsolated`
/// states an invariant the compiler cannot check, and the `Thread.isMainThread` branch below
/// substitutes a runtime test for a static guarantee.
///
/// The underlying problem is that ``CodeFileDocument`` mixes main-actor UI state (`content` is an
/// `NSTextStorage` SwiftUI observes) with an I/O lifecycle AppKit drives from arbitrary threads.
/// The proper fix separates the two: decode into a `Sendable` value with no isolation, then install
/// it in one main-actor step. That is a redesign of the document's state ownership, deliberately
/// deferred. See `docs/architecture-decisions.md`, "Document isolation is bridged, not solved".
extension CodeFileDocument {
    /// Handle the notification that the represented file item changed.
    ///
    /// We check if a file has been modified and can be read again to display to the user.
    /// To determine if a file has changed, we check the modification date. If it's different from the stored one,
    /// we continue.
    /// To determine if we can reload the file, we check if the document has outstanding edits. If not, we reload the
    /// file.
    override public func presentedItemDidChange() {
        // Unlike reads, this genuinely arrives on the file-presenter thread, while the state it
        // consults is main-actor isolated. This blocks the presenter thread intentionally: if we
        // don't wait, we'll receive more updates that the file has changed and end up dispatching
        // multiple reads. The presenter thread expects this to be synchronous anyway.

        // https://github.com/CodeEditApp/CodeEdit/issues/2091
        // We can't use `.asyncAndWait` on Ventura as it seems the symbol is missing on that
        // platform. Could be just for x86 machines.
        let reloadIfClean: @MainActor () -> Bool = { [self] in
            guard fileModificationDate != getModificationDate(), !isDocumentEdited else {
                return false
            }
            fileModificationDate = getModificationDate()
            if let fileURL, let fileType {
                try? read(from: fileURL, ofType: fileType)
            }
            return true
        }

        // Callers are not all off-main: `NSFileCoordinator` delivers on the presenter thread, but
        // tests (and any future in-process caller) may already be on the main thread, where
        // `DispatchQueue.main.sync` would deadlock. Mirrors the branch in ``notifyLSPDidOpen()``.
        let handled = Thread.isMainThread
            ? MainActor.assumeIsolated { reloadIfClean() }
            : DispatchQueue.main.sync { MainActor.assumeIsolated { reloadIfClean() } }

        if !handled {
            super.presentedItemDidChange()
        }
    }

    /// Helper to find the last modified date of the represented file item.
    /// 
    /// Different from `NSDocument.fileModificationDate`. This returns the *current* modification date, whereas the
    /// alternative stores the date that existed when we last read the file.
    private func getModificationDate() -> Date? {
        guard let path = fileURL?.absolutePath else { return nil }
        return try? FileManager.default.attributesOfItem(atPath: path)[.modificationDate] as? Date
    }
}

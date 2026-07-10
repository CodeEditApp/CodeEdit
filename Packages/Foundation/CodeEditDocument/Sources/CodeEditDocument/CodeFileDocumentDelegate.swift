//
//  CodeFileDocumentDelegate.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import AppKit
import CodeEditTextView

/// The app-provided capabilities a `CodeFileDocument` needs from its host application
/// (undo registry, standalone-window content, and language-server lifecycle). Keeps the
/// document free of `Workspace`, Settings-view, and `LSPService` references.
///
/// A single shared delegate is wired by the app at launch via
/// ``CodeFileDocument/delegateProvider`` rather than a per-instance `weak var delegate`,
/// so that framework-created documents (`init()` → `read()` fires `documentDidOpen` before
/// any completion handler could set a per-instance delegate) get correct timing without a
/// custom `NSDocumentController`.
@MainActor
public protocol CodeFileDocumentDelegate: AnyObject {
    /// The undo manager already registered for a file, if any (nil if none exists yet).
    func undoManager(forFile url: URL) -> CEUndoManager?
    /// The content view for a standalone single-file window (`makeWindowControllers`).
    func makeWindowContentView(for document: CodeFileDocument) -> NSView
    /// The document finished reading its contents and is now open.
    func documentDidOpen(_ document: CodeFileDocument)
    /// The document at `url` closed.
    func documentDidClose(at url: URL)
}

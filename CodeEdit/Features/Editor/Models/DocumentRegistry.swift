//
//  DocumentRegistry.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 06/07/2026.
//

import Combine
import Foundation
import CodeEditCore

/// Owns the workspace's file→document association, keyed by ``CEWorkspaceFile/id``.
///
/// Storage is intentionally **weak** and change notification uses a `PassthroughSubject`,
/// mirroring the reference that previously lived (type-erased) on `CEWorkspaceFile`. The
/// strong owner of an open document remains the editor view tree; this registry only holds
/// the back-reference that non-view consumers read.
///
/// Only ever accessed on the main thread, like the rest of the editor state. It is intentionally
/// **not** `@MainActor`: its owner (`EditorManager`) and callers are not yet actor-isolated, and
/// marking only this type does not compile in the app's current Swift 5 mode. It should become
/// `@MainActor` together with `EditorManager` during the eventual app-wide Swift 6 migration.
final class DocumentRegistry {
    private final class Box {
        weak var document: CodeFileDocument?
        let subject = PassthroughSubject<CodeFileDocument?, Never>()
    }

    private var boxes: [String: Box] = [:]

    private func box(for id: String) -> Box {
        if let existing = boxes[id] { return existing }
        let created = Box()
        boxes[id] = created
        return created
    }

    /// The open document for the file, or `nil` if none is loaded.
    func document(for file: CEWorkspaceFile) -> CodeFileDocument? {
        boxes[file.id]?.document
    }

    /// Associates (or clears, with `nil`) a document for the file and notifies subscribers.
    func setDocument(_ document: CodeFileDocument?, for file: CEWorkspaceFile) {
        let box = box(for: file.id)
        box.document = document
        box.subject.send(document)
    }

    /// Loads a new `CodeFileDocument` for the file from disk, registers it, and returns it.
    @discardableResult
    func loadDocument(for file: CEWorkspaceFile) throws -> CodeFileDocument {
        let document = try CodeFileDocument(
            contentsOf: file.resolvedURL,
            ofType: file.contentType?.identifier ?? ""
        )
        setDocument(document, for: file)
        return document
    }

    /// Emits whenever the document association for the file changes. Like the original,
    /// this does not replay the current value on subscription.
    func documentPublisher(for file: CEWorkspaceFile) -> AnyPublisher<CodeFileDocument?, Never> {
        box(for: file.id).subject.eraseToAnyPublisher()
    }
}

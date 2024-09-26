//
//  LSPContentCoordinator.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/12/24.
//

import AppKit
import AsyncAlgorithms
import CodeEditSourceEditor
import CodeEditTextView
import LanguageServerProtocol

/// This content coordinator forwards content notifications from the editor's text storage to a language service.
///
/// This is a text view coordinator so that it can be installed on an open editor. It is kept as a property on
/// ``CodeFileDocument`` since the language server does all it's document management using instances of that type.
class LSPContentCoordinator: TextViewCoordinator, TextViewDelegate {
    // Required to avoid a large_tuple lint error
    private struct SequenceElement: Sendable {
        let uri: String
        let range: LSPRange
        let string: String
    }

    private var editedRange: LSPRange?
    private var stream: AsyncStream<SequenceElement>?
    private var sequenceContinuation: AsyncStream<SequenceElement>.Continuation?
    private var task: Task<Void, Never>?

    weak var languageServer: LanguageServer?
    var uri: String?

    init() {
        self.stream = AsyncStream { continuation in
            self.sequenceContinuation = continuation
        }
    }

    func setUpUpdatesTask() {
        task?.cancel()
        guard let stream else { return }
        task = Task { [weak self] in
            // Check for editing events every 250 ms
            for await events in stream.chunked(by: .repeating(every: .milliseconds(250), clock: .continuous)) {
                guard !Task.isCancelled, self != nil else { return }
                guard !events.isEmpty, let uri = events.first?.uri else { continue }
                Task.detached { [weak self] in
                    try await self?.languageServer?.documentChanged(
                        uri: uri,
                        changes: events.map {
                            LanguageServer.DocumentChange(replacingContentsIn: $0.range, with: $0.string)
                        }
                    )
                }
            }
        }
    }

    func prepareCoordinator(controller: TextViewController) {
        setUpUpdatesTask()
    }

    /// We grab the lsp range before the content (and layout) is changed so we get correct line/col info for the
    /// language server range.
    func textView(_ textView: TextView, willReplaceContentsIn range: NSRange, with string: String) {
        self.editedRange = textView.lspRangeFrom(nsRange: range)
    }

    func textView(_ textView: TextView, didReplaceContentsIn range: NSRange, with string: String) {
        guard let uri,
              let lspRange = editedRange else {
            return
        }
        self.editedRange = nil
        self.sequenceContinuation?.yield(SequenceElement(uri: uri, range: lspRange, string: string))
    }

    func destroy() {
        task?.cancel()
        task = nil
        sequenceContinuation?.finish()
        sequenceContinuation = nil
    }

    deinit {
        destroy()
    }
}

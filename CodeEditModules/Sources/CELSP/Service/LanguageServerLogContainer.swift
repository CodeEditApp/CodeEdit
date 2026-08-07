//
//  LanguageServerLogContainer.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/18/25.
//

import Foundation
import LanguageServerProtocol

/// Collects a language server's log messages. UtilityArea adapts this to its output
/// protocols app-side (`LanguageServerLogContainer+UtilityArea.swift`).
///
/// `@unchecked Sendable`: logs arrive from server event streams and process
/// termination handlers on arbitrary threads; all access to `logs` is guarded
/// by `logLock`.
public final class LanguageServerLogContainer: @unchecked Sendable {
    public struct LanguageServerMessage: Identifiable {
        public let log: LogMessageParams
        public var id: UUID = UUID()

        public var message: String {
            log.message
        }

        public var date: Date = Date()
        public var subsystem: String?
        public var category: String?
    }

    public let id: String

    private let streamContinuation: AsyncStream<LanguageServerMessage>.Continuation
    private let stream: AsyncStream<LanguageServerMessage>
    private let logLock = NSLock()
    private var logs: [LanguageServerMessage] = []

    public init(language: LanguageIdentifier) {
        id = language.rawValue
        (stream, streamContinuation) = AsyncStream<LanguageServerMessage>.makeStream(
            bufferingPolicy: .bufferingNewest(0)
        )
    }

    public func appendLog(_ log: LogMessageParams) {
        let message = LanguageServerMessage(log: log)
        logLock.withLock {
            logs.append(message)
        }
        streamContinuation.yield(message)
    }

    public func cachedMessages() -> [LanguageServerMessage] {
        logLock.withLock { logs }
    }

    public func streamMessages() -> AsyncStream<LanguageServerMessage> {
        stream
    }
}

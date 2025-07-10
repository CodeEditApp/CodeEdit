//
//  EditorStateRestoration.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/20/25.
//

import Foundation
import GRDB
import CodeEditSourceEditor
import OSLog

/// CodeEdit attempts to store and retrieve editor state for open tabs to restore the user's scroll position and
/// cursor positions between sessions. This class manages the storage mechanism to facilitate that feature.
///
/// This creates a sqlite database in the application support directory named `editor-restoration.db`.
///
/// To ensure we can query this quickly, this class is shared globally (to avoid having to use a database pool) and
/// all writes and reads are synchronous.
///
/// # If changes are required
///
/// Use the database migrator in the initializer for this class, see GRDB's documentation for adding a migration
/// version. **Do not ever** delete migration versions that have made it to a released version of CodeEdit.
final class EditorStateRestoration {
    /// Optional here so we can gracefully catch errors.
    /// The nice thing is this feature is optional in that if we don't have it available the user's experience is
    /// degraded but not catastrophic.
    static let shared: EditorStateRestoration? = try? EditorStateRestoration()

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "",
        category: "EditorStateRestoration"
    )

    struct StateRestorationRecord: Codable, TableRecord, FetchableRecord, PersistableRecord {
        let uri: String
        let data: Data
    }

    struct StateRestorationData: Codable, Equatable {
        // Cursor positions as range values (not row/column!)
        let cursorPositions: [Range<Int>]
        let scrollPositionX: Double
        let scrollPositionY: Double

        var scrollPosition: CGPoint {
            CGPoint(x: scrollPositionX, y: scrollPositionY)
        }

        var editorCursorPositions: [CursorPosition] {
            cursorPositions.map { CursorPosition(range: NSRange(start: $0.lowerBound, end: $0.upperBound)) }
        }

        init(cursorPositions: [CursorPosition], scrollPosition: CGPoint) {
            self.cursorPositions = cursorPositions
                .compactMap { $0.range }
                .map { $0.location..<($0.location + $0.length) }
            self.scrollPositionX = scrollPosition.x
            self.scrollPositionY = scrollPosition.y
        }
    }

    private var databaseQueue: DatabaseQueue?
    private var databaseURL: URL

    /// Create a new editor restoration object. Will connect to or create a SQLite db.
    /// - Parameter databaseURL: The database URL to use. Must point to a file, not a directory. If left `nil`, will
    ///                          create a new database named `editor-restoration.db` in the application support
    ///                          directory.
    init(_ databaseURL: URL? = nil) throws {
        self.databaseURL = databaseURL ?? FileManager.default
            .homeDirectoryForCurrentUser
            .appending(path: "Library/Application Support/CodeEdit", directoryHint: .isDirectory)
            .appending(path: "editor-restoration.db", directoryHint: .notDirectory)
        try attemptMigration(retry: true)
    }

    func attemptMigration(retry: Bool) throws {
        do {
            let databaseQueue = try DatabaseQueue(path: self.databaseURL.absolutePath, configuration: .init())

            var migrator = DatabaseMigrator()

            migrator.registerMigration("Version 0") {
                try $0.create(table: "stateRestorationRecord") { table in
                    table.column("uri", .text).primaryKey().notNull()
                    table.column("data", .blob).notNull()
                }
            }

            try migrator.migrate(databaseQueue)
            self.databaseQueue = databaseQueue
        } catch {
            if retry {
                // Try to delete the database on failure, might fix a corruption or version error.
                try? FileManager.default.removeItem(at: databaseURL)
                try attemptMigration(retry: false)

                return // Ignore the original error if we're retrying
            }
            Self.logger.error("Failed to start database connection: \(error)")
            throw error
        }
    }

    /// Update saved restoration state of a document.
    /// - Parameters:
    ///   - documentUrl: The URL of the document.
    ///   - data: The data to store for the file, retrieved using ``restorationState(for:)``.
    func updateRestorationState(for documentUrl: URL, data: StateRestorationData) {
        do {
            let serializedData = try JSONEncoder().encode(data)
            let dbRow = StateRestorationRecord(uri: documentUrl.absolutePath, data: serializedData)
            try databaseQueue?.write { try dbRow.upsert($0) }
        } catch {
            Self.logger.error("Failed to save editor state: \(error)")
        }
    }

    /// Find the restoration state for a document.
    /// - Parameter documentUrl: The URL of the document.
    /// - Returns: Any data saved for this file.
    func restorationState(for documentUrl: URL) -> StateRestorationData? {
        do {
            guard let row = try databaseQueue?.read({
                try StateRestorationRecord.fetchOne($0, key: documentUrl.absolutePath)
            }) else {
                return nil
            }
            let decodedData = try JSONDecoder().decode(StateRestorationData.self, from: row.data)
            return decodedData
        } catch {
            Self.logger.error("Failed to find editor state for '\(documentUrl.absolutePath)': \(error)")
        }
        return nil
    }
}

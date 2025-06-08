//
//  IssueNodes.swift
//  CodeEdit
//
//  Created by Abe Malla on 6/7/25.
//

import SwiftUI
import LanguageServerProtocol

/// Protocol defining the common interface for nodes in the issue navigator
protocol IssueNode: Identifiable, Hashable {
    var id: UUID { get }
    var name: String { get }
    var isExpandable: Bool { get }
    var nsIcon: NSImage { get }
}

/// Represents the project (root) node in the issue navigator
class ProjectIssueNode: IssueNode, ObservableObject, Equatable {
    let id: UUID = UUID()
    let name: String

    @Published var files: [FileIssueNode]
    @Published var isExpanded: Bool

    var nsIcon: NSImage {
        return NSImage(systemSymbolName: "folder.fill", accessibilityDescription: "Root folder")!
    }

    var isExpandable: Bool {
        !files.isEmpty
    }

    var diagnosticsCount: Int {
        files.reduce(0) { $0 + $1.diagnostics.count }
    }

    var errorCount: Int {
        files.reduce(0) { $0 + $1.diagnostics.filter { $0.diagnostic.severity == .error }.count }
    }

    var warningCount: Int {
        files.reduce(0) { $0 + $1.diagnostics.filter { $0.diagnostic.severity == .warning }.count }
    }

    init(name: String, files: [FileIssueNode] = [], isExpanded: Bool = true) {
        self.name = name
        self.files = files
        self.isExpanded = isExpanded
    }

    static func == (lhs: ProjectIssueNode, rhs: ProjectIssueNode) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Represents a file node in the issue navigator
class FileIssueNode: IssueNode, ObservableObject, Equatable {
    let id: UUID = UUID()
    let uri: DocumentUri
    let name: String

    @Published var diagnostics: [DiagnosticIssueNode]
    @Published var isExpanded: Bool

    /// Returns the extension of the file or an empty string if no extension is present.
    var type: FileIcon.FileType {
        let fileExtension = (uri as NSString).pathExtension.lowercased()
        if !fileExtension.isEmpty {
            if let type = FileIcon.FileType(rawValue: fileExtension) {
                return type
            }
        }
        return .txt
    }

    /// Returns a `Color` for a specific `fileType`
    ///
    /// If not specified otherwise this will return `Color.accentColor`
    var iconColor: SwiftUI.Color {
        FileIcon.iconColor(fileType: type)
    }

    /// Return the icon of the file as `NSImage`
    var nsIcon: NSImage {
        let systemImage = FileIcon.fileIcon(fileType: type)
        if let customImage = NSImage.symbol(named: systemImage) {
            return customImage
        } else {
            return NSImage(systemSymbolName: systemImage, accessibilityDescription: systemImage)
                ?? NSImage(systemSymbolName: "doc", accessibilityDescription: "doc")!
        }
    }

    var isExpandable: Bool {
        !diagnostics.isEmpty
    }

    var errorCount: Int {
        diagnostics.filter { $0.diagnostic.severity == .error }.count
    }

    var warningCount: Int {
        diagnostics.filter { $0.diagnostic.severity == .warning }.count
    }

    init(uri: DocumentUri, name: String? = nil, diagnostics: [DiagnosticIssueNode] = [], isExpanded: Bool = false) {
        self.uri = uri
        self.name = name ?? (URL(string: uri)?.lastPathComponent ?? "Unknown")
        self.diagnostics = diagnostics
        self.isExpanded = isExpanded
    }

    static func == (lhs: FileIssueNode, rhs: FileIssueNode) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Represents a diagnostic node in the issue navigator
class DiagnosticIssueNode: IssueNode, ObservableObject, Equatable {
    let id: UUID = UUID()
    let diagnostic: Diagnostic
    let fileUri: DocumentUri

    var name: String {
        diagnostic.message.trimmingCharacters(in: .newlines)
    }

    var isExpandable: Bool {
        false
    }

    var nsIcon: NSImage {
        switch diagnostic.severity {
        case .error:
            return NSImage(
                systemSymbolName: "xmark.octagon.fill",
                accessibilityDescription: "Error"
            )!
        case .warning:
            return NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: "Warning")!
        case .information:
            return NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: "Information")!
        case .hint:
            return NSImage(systemSymbolName: "lightbulb.fill", accessibilityDescription: "Hint")!
        case nil:
            return NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Unknown Issue Type")!
        }
    }

    var severityColor: NSColor {
        switch diagnostic.severity {
        case .error:
            return .errorRed
        case .warning:
            return .warningYellow
        case .information:
            return .blue
        case .hint:
            return .gray
        case nil:
            return .secondaryLabelColor
        }
    }

    var locationString: String {
        "Line \(diagnostic.range.start.line + 1), Column \(diagnostic.range.start.character + 1)"
    }

    init(diagnostic: Diagnostic, fileUri: DocumentUri) {
        self.diagnostic = diagnostic
        self.fileUri = fileUri
    }

    static func == (lhs: DiagnosticIssueNode, rhs: DiagnosticIssueNode) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

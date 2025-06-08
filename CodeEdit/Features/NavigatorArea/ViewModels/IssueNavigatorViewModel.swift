//
//  IssueNavigatorViewModel.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/15/25.
//

import Combine
import SwiftUI
import Foundation
import LanguageServerProtocol

class IssueNavigatorViewModel: ObservableObject {
    @Published var rootNode: ProjectIssueNode?
    @Published var filterOptions = IssueFilterOptions()
    @Published private(set) var filteredRootNode: ProjectIssueNode?

    let diagnosticsDidChangePublisher = PassthroughSubject<Void, Never>()

    // Store file nodes by URI for efficient lookup and to avoid duplication
    private var fileNodesByUri: [DocumentUri: FileIssueNode] = [:]

    // Track expansion state separately to persist it
    private var expandedFileUris: Set<DocumentUri> = []

    func initialize(projectName: String) {
        self.rootNode = ProjectIssueNode(name: projectName)
        self.filteredRootNode = ProjectIssueNode(name: projectName)
    }

    func updateDiagnostics(params: PublishDiagnosticsParams) {
        let uri = params.uri
        let diagnostics = params.diagnostics

        if diagnostics.isEmpty {
            // Remove the file node if no diagnostics
            fileNodesByUri.removeValue(forKey: uri)
            expandedFileUris.remove(uri)
        } else {
            // Get or create file node
            let fileNode: FileIssueNode
            if let existingNode = fileNodesByUri[uri] {
                fileNode = existingNode
                // Clear existing diagnostics
                fileNode.diagnostics.removeAll(keepingCapacity: true)
            } else {
                // Create new file node
                let fileName = getFileName(from: uri)
                fileNode = FileIssueNode(uri: uri, name: fileName)
                fileNodesByUri[uri] = fileNode
            }

            // Convert diagnostics to diagnostic nodes and add to file node
            let diagnosticNodes = diagnostics.map { diagnostic in
                DiagnosticIssueNode(diagnostic: diagnostic, fileUri: uri)
            }

            // Sort diagnostics by severity and line number
            let sortedDiagnosticNodes = diagnosticNodes.sorted { node1, node2 in
                let severity1 = node1.diagnostic.severity?.rawValue ?? Int.max
                let severity2 = node2.diagnostic.severity?.rawValue ?? Int.max

                if severity1 == severity2 {
                    // If same severity, sort by line number
                    return node1.diagnostic.range.start.line < node2.diagnostic.range.start.line
                }

                return severity1 < severity2
            }

            fileNode.diagnostics = sortedDiagnosticNodes

            // Restore expansion state if it was previously expanded
            if expandedFileUris.contains(uri) {
                fileNode.isExpanded = true
            }
        }

        rebuildTree()
        diagnosticsDidChangePublisher.send()
    }

    func clearDiagnostics() {
        fileNodesByUri.removeAll()
        expandedFileUris.removeAll()
        rebuildTree()
        diagnosticsDidChangePublisher.send()
    }

    func removeDiagnostics(uri: DocumentUri) {
        fileNodesByUri.removeValue(forKey: uri)
        expandedFileUris.remove(uri)
        rebuildTree()
        diagnosticsDidChangePublisher.send()
    }

    func updateFilter(options: IssueFilterOptions) {
        self.filterOptions = options
        applyFilter()
        diagnosticsDidChangePublisher.send()
    }

    /// Save expansion state for a file
    func setFileExpanded(_ uri: DocumentUri, isExpanded: Bool) {
        if isExpanded {
            expandedFileUris.insert(uri)
        } else {
            expandedFileUris.remove(uri)
        }

        if let fileNode = fileNodesByUri[uri] {
            fileNode.isExpanded = isExpanded
        }
    }

    /// Get all expanded file URIs for persistence
    func getExpandedFileUris() -> Set<DocumentUri> {
        return expandedFileUris
    }

    /// Restore expansion state from persisted data
    func restoreExpandedFileUris(_ uris: Set<DocumentUri>) {
        expandedFileUris = uris

        // Apply to existing file nodes
        for uri in uris {
            if let fileNode = fileNodesByUri[uri] {
                fileNode.isExpanded = true
            }
        }
    }

    private func applyFilter() {
        guard let rootNode else { return }
        let filteredRoot = ProjectIssueNode(name: rootNode.name)
        filteredRoot.isExpanded = rootNode.isExpanded

        // Filter files and diagnostics
        for fileNode in rootNode.files {
            let filteredDiagnostics = fileNode.diagnostics.filter {
                filterOptions.shouldShow(diagnostic: $0.diagnostic)
            }

            if !filteredDiagnostics.isEmpty {
                let filteredFileNode = FileIssueNode(
                    uri: fileNode.uri,
                    name: fileNode.name,
                    diagnostics: filteredDiagnostics,
                    isExpanded: fileNode.isExpanded
                )
                filteredRoot.files.append(filteredFileNode)
            }
        }

        filteredRoot.files.sort { $0.name < $1.name }
        filteredRootNode = filteredRoot
    }

    /// Rebuilds the tree structure based on current diagnostics
    private func rebuildTree() {
        guard let rootNode else { return }

        let projectExpanded = rootNode.isExpanded
        let sortedFileNodes = fileNodesByUri.values
            .sorted { $0.name < $1.name }

        rootNode.files = sortedFileNodes
        rootNode.isExpanded = projectExpanded

        applyFilter()
    }

    /// Extracts file name from document URI
    private func getFileName(from uri: DocumentUri) -> String {
        if let url = URL(string: uri) {
            return url.lastPathComponent
        }

        let components = uri.split(separator: "/")
        return String(components.last ?? "Unknown")
    }

    func getAllDiagnostics() -> [Diagnostic] {
        return fileNodesByUri.values.flatMap { fileNode in
            fileNode.diagnostics.map { $0.diagnostic }
        }
    }

    func getDiagnostics(for uri: DocumentUri) -> [Diagnostic]? {
        return fileNodesByUri[uri]?.diagnostics.map { $0.diagnostic }
    }

    func getFileNode(for uri: DocumentUri) -> FileIssueNode? {
        return fileNodesByUri[uri]
    }

    func getDiagnosticCountBySeverity() -> [DiagnosticSeverity?: Int] {
        let allDiagnostics = getAllDiagnostics()
        var countBySeverity: [DiagnosticSeverity?: Int] = [:]

        for severity in DiagnosticSeverity.allCases {
            countBySeverity[severity] = allDiagnostics.filter { $0.severity == severity }.count
        }

        countBySeverity[nil] = allDiagnostics.filter { $0.severity == nil }.count
        return countBySeverity
    }

    func getDiagnosticAt(uri: DocumentUri, line: Int, character: Int) -> Diagnostic? {
        guard let fileNode = fileNodesByUri[uri] else { return nil }

        return fileNode.diagnostics.first { diagnosticNode in
            let range = diagnosticNode.diagnostic.range

            // Check if position is within the diagnostic range
            if line < range.start.line || line > range.end.line {
                return false
            }
            if line == range.start.line && character < range.start.character {
                return false
            }
            if line == range.end.line && character > range.end.character {
                return false
            }
            return true
        }?.diagnostic
    }
}

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

/// Options for filtering diagnostics in the issue navigator
struct IssueFilterOptions {
    var showErrors: Bool = true
    var showWarnings: Bool = true
    var showInformation: Bool = true
    var showHints: Bool = true
    var searchText: String = ""

    func shouldShow(diagnostic: Diagnostic) -> Bool {
        if let severity = diagnostic.severity {
            switch severity {
            case .error:
                guard showErrors else { return false }
            case .warning:
                guard showWarnings else { return false }
            case .information:
                guard showInformation else { return false }
            case .hint:
                guard showHints else { return false }
            }
        }

        if !searchText.isEmpty {
            return diagnostic.message.lowercased().contains(searchText.lowercased())
        }
        return true
    }
}

//
//  IssueNavigatorViewModel.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/15/25.
//

import SwiftUI
import Foundation
import LanguageServerProtocol

class IssueNavigatorViewModel: ObservableObject {
    @Published var rootNode: ProjectIssueNode
    @Published var filterOptions = IssueFilterOptions()
    @Published private(set) var filteredRootNode: ProjectIssueNode

    private var diagnosticsByFile: [DocumentUri: [Diagnostic]] = [:]

    init(projectName: String) {
        self.rootNode = ProjectIssueNode(name: projectName)
        self.filteredRootNode = ProjectIssueNode(name: projectName)
    }

    func updateDiagnostics(params: PublishDiagnosticsParams) {
        let uri = params.uri
        let diagnostics = params.diagnostics

        if diagnostics.isEmpty {
            diagnosticsByFile.removeValue(forKey: uri)
        } else {
            diagnosticsByFile[uri] = diagnostics
        }

        rebuildTree()
    }

    func clearDiagnostics() {
        diagnosticsByFile.removeAll()
        rebuildTree()
    }

    func removeDiagnostics(uri: DocumentUri) {
        diagnosticsByFile.removeValue(forKey: uri)
        rebuildTree()
    }

    func updateFilter(options: IssueFilterOptions) {
        self.filterOptions = options
        applyFilter()
    }

    private func applyFilter() {
        let filteredRoot = ProjectIssueNode(name: rootNode.name)

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
        // Keep track of expanded states for files
        let expandedFileUris = Set(rootNode.files
            .filter { $0.isExpanded }
            .map { $0.uri })

        // Create file nodes with diagnostics
        let fileNodes = diagnosticsByFile.compactMap { (uri, diagnostics) -> FileIssueNode? in
            guard !diagnostics.isEmpty else { return nil }

            let fileName = getFileName(from: uri)
            let diagnosticNodes = diagnostics.map { DiagnosticIssueNode(diagnostic: $0, fileUri: uri) }

            // Sort diagnostics by severity
            let sortedDiagnosticNodes = diagnosticNodes.sorted { node1, node2 in
                let severity1 = node1.diagnostic.severity?.rawValue ?? Int.max
                let severity2 = node2.diagnostic.severity?.rawValue ?? Int.max

                if severity1 == severity2 {
                    // If same severity, sort by line number
                    return node1.diagnostic.range.start.line < node2.diagnostic.range.start.line
                }

                return severity1 < severity2
            }

            let fileNode = FileIssueNode(uri: uri, name: fileName, diagnostics: sortedDiagnosticNodes)
            fileNode.isExpanded = expandedFileUris.contains(uri)
            return fileNode
        }

        let sortedFileNodes = fileNodes.sorted { $0.name < $1.name }
        rootNode.files = sortedFileNodes
        applyFilter()
    }

    /// Extracts file name from document URI
    private func getFileName(from uri: DocumentUri) -> String {
        if let url = URL(string: uri) {
            return url.lastPathComponent
        }

        let components = uri.split(separator: "/")
        return String(components.last ?? "")
    }

    func getAllDiagnostics() -> [Diagnostic] {
        return diagnosticsByFile.values.flatMap { $0 }
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
        guard let diagnostics = diagnosticsByFile[uri] else { return nil }

        return diagnostics.first { diagnostic in
            let range = diagnostic.range

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
        }
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
class ProjectIssueNode: IssueNode, ObservableObject {
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
class FileIssueNode: IssueNode, ObservableObject {
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

    init(uri: DocumentUri, name: String, diagnostics: [DiagnosticIssueNode] = [], isExpanded: Bool = true) {
        self.uri = uri
        self.name = name
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
class DiagnosticIssueNode: IssueNode, ObservableObject {
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
            return NSImage(systemSymbolName: "exclamationmark.octagon.fill", accessibilityDescription: "")!
        case .warning:
            return NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: "")!
        case .information:
            return NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: "")!
        case .hint:
            return NSImage(systemSymbolName: "lightbulb.fill", accessibilityDescription: "")!
        case nil:
            return NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "")!
        }
    }

    var severityColor: NSColor {
        switch diagnostic.severity {
        case .error:
            return .red
        case .warning:
            return .yellow
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
